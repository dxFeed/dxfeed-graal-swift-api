//
//  Diagnostic.swift
//  DxFeedPertTestApp
//
//  Created by Aleksey Kosylo on 14.06.23.
//

import Foundation

private class Counter {
    private (set) var value: Int64 = 0
    func add (_ amount: Int64) {
        OSAtomicAdd64(amount, &value)
    }
}

struct Metrics {
    let rateOfEvent: NSNumber
    let rateOfListeners: NSNumber
    let numberOfEvents: NSNumber
    let cpuUsage: NSNumber
    let peakCpuUsage: NSNumber
    let memmoryUsage: NSNumber
    let peakMemmoryUsage: NSNumber
    let currentTime: TimeInterval
}

class Diagnostic {
    private var absoluteStartTime: Date?

    private var cpuUsage: Double = 0
    private var peakCpuUsage: Double = 0

    private var memmoryUsage: Double = 0
    private var peakMemmoryUsage: Double = 0

    private var startTime = Date.now

    private var counter = Counter()
    private var counterListener = Counter()

    private var lastValue: Int64 = 0
    private var lastListenerValue: Int64 = 0

    let coresCount = ProcessInfo.processInfo.processorCount

    func getMetrics() -> Metrics {
        let lastStart = self.startTime
        let currentValue = self.counter.value
        let currentListenerValue = self.counterListener.value

        self.startTime = Date.now
        if absoluteStartTime == nil {
            absoluteStartTime = self.startTime
        }
        let seconds = self.startTime.timeIntervalSince(lastStart)
        let speed = seconds == 0 ? 0 : Double(currentValue - self.lastValue) / seconds

        let speedListener =  Double(currentListenerValue - self.lastListenerValue) / seconds
        let eventsIncall = speed / speedListener

        self.lastValue = currentValue
        self.lastListenerValue = currentListenerValue

        return Metrics(rateOfEvent: NSNumber(value: speed),
                       rateOfListeners: NSNumber(value: speedListener),
                       numberOfEvents: NSNumber(value: eventsIncall),
                       cpuUsage: NSNumber(value: cpuUsage),
                       peakCpuUsage: NSNumber(value: peakCpuUsage),
                       memmoryUsage: NSNumber(value: memmoryUsage),
                       peakMemmoryUsage: NSNumber(value: peakMemmoryUsage),
                       currentTime: startTime.timeIntervalSince(absoluteStartTime ?? startTime))
    }

    func updateCounters(_ count: Int64) {
        counter.add(count)
        counterListener.add(1)
    }

    func updateCpuUsage() {
        memmoryUsage = calculateMemmoryUsage()
        peakMemmoryUsage = max(peakMemmoryUsage, memmoryUsage)
        cpuUsage = calculateCpuUsage()
        peakCpuUsage = max(peakCpuUsage, cpuUsage)
    }

    private func calculateCpuUsage() -> Double {
        var kernelReturn: kern_return_t
        var taskInfoCount: mach_msg_type_number_t

        taskInfoCount = mach_msg_type_number_t(TASK_INFO_MAX)
        var tinfo = [integer_t](repeating: 0, count: Int(taskInfoCount))

        kernelReturn = task_info(mach_task_self_, task_flavor_t(TASK_BASIC_INFO), &tinfo, &taskInfoCount)
        if kernelReturn != KERN_SUCCESS {
            return -1
        }

        var threadList: thread_act_array_t? = UnsafeMutablePointer<thread_act_t>.allocate(capacity: 1)
        var threadCount: mach_msg_type_number_t = 0
        defer {
            if let threadList = threadList {
                vm_deallocate(mach_task_self_, vm_address_t(UnsafePointer(threadList).pointee), vm_size_t(threadCount))
            }
        }

        kernelReturn = task_threads(mach_task_self_, &threadList, &threadCount)

        if kernelReturn != KERN_SUCCESS {
            return -1
        }

        var totCpu: Double = 0

        if let threadList = threadList {

            for jIndex in 0 ..< Int(threadCount) {
                var threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
                var thinfo = [integer_t](repeating: 0, count: Int(threadInfoCount))
                kernelReturn = thread_info(threadList[jIndex], thread_flavor_t(THREAD_BASIC_INFO),
                                 &thinfo, &threadInfoCount)
                if kernelReturn != KERN_SUCCESS {
                    return -1
                }

                let threadBasicInfo = convertThreadInfoToThreadBasicInfo(thinfo)

                if threadBasicInfo.flags != TH_FLAGS_IDLE {
                    totCpu += (Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE)) * 100.0
                }
            } // for each thread
        }
        let result = totCpu / Double(coresCount)
        return result
    }

    func calculateMemmoryUsage() -> Double {
        var taskInfo = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info>.size) / 4
        _ = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        let usedMb = Double(taskInfo.phys_footprint) / 1048576.0
        return usedMb
    }

    private func convertThreadInfoToThreadBasicInfo(_ threadInfo: [integer_t]) -> thread_basic_info {
        var result = thread_basic_info()

        result.user_time = time_value_t(seconds: threadInfo[0], microseconds: threadInfo[1])
        result.system_time = time_value_t(seconds: threadInfo[2], microseconds: threadInfo[3])
        result.cpu_usage = threadInfo[4]
        result.policy = threadInfo[5]
        result.run_state = threadInfo[6]
        result.flags = threadInfo[7]
        result.suspend_count = threadInfo[8]
        result.sleep_time = threadInfo[9]

        return result
    }

    func cleanTime() {
        absoluteStartTime = nil
    }
}
