//
//  PerfTestViewController.swift
//  TestApp
//
//  Created by Aleksey Kosylo on 07.06.23.
//

import UIKit
import DxFeedSwiftFramework

class Counter {
    private (set) var value: Int64 = 0
    func add (_ amount: Int64) {
        OSAtomicAdd64(amount, &value)
    }
}

struct Colors {
    let background = UIColor(red: 18/255, green: 16/255, blue: 49/255, alpha: 1.0)
    let cellBackground = UIColor(red: 31/255, green: 30/255, blue: 65/255, alpha: 1.0)

    let priceBackground = UIColor(red: 60/255, green: 62/255, blue: 101/255, alpha: 1.0)
    let green = UIColor(red: 0/255, green: 117/255, blue: 91/255, alpha: 1.0)
    let red = UIColor(red: 147/255, green: 0/255, blue: 36/255, alpha: 1.0)
}

class PerfTestViewController: UIViewController {
    var counter = Counter()
    var counterListener = Counter()

    let numberFormatter = NumberFormatter()
    var startTime = Date.now
    var lastValue: Int64 = 0
    var lastListenerValue: Int64 = 0
    var maxCpuUsage: Double = 0

    private var endpoint: DXEndpoint?
    private var subscription: DXFeedSubcription?
    private var profileSubscription: DXFeedSubcription?

    var symbols = ["ETH/USD:GDAX"]
    var blackHoleInt: Int64 = 0

    var isConnected = false

    @IBOutlet var connectionStatusLabel: UILabel!
    @IBOutlet var connectButton: UIButton!
    @IBOutlet var addressTextField: UITextField!


    @IBOutlet var rateOfEventsLabel: UILabel!
    @IBOutlet var rateOfEventsCounter: UILabel!

    @IBOutlet var rateOfListenersLabel: UILabel!
    @IBOutlet var rateOfListenersCounter: UILabel!

    @IBOutlet var numberOfEventsLabel: UILabel!
    @IBOutlet var numberOfEventsCounter: UILabel!

    @IBOutlet var currentCpuLabel: UILabel!
    @IBOutlet var currentCpuCounter: UILabel!

    @IBOutlet var peakCpuUsageLabel: UILabel!
    @IBOutlet var peakCpuUsageCounter: UILabel!

    let colors = Colors()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
        
        self.connectionStatusLabel.text = DXEndpointState.notConnected.convetToString()        
        numberFormatter.numberStyle = .decimal

        self.view.backgroundColor = colors.background

        try? SystemProperty.setProperty("com.devexperts.connector.proto.heartbeatTimeout", "10s")

        DispatchQueue.global(qos: .background).async {
                Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
                    self.updateUI()
                }
                RunLoop.current.run()
        }
    }

    func updateUI() {
        let lastStart = self.startTime
        let currentValue = self.counter.value
        let currentListenerValue = self.counterListener.value

        self.startTime = Date.now
        let seconds = Date.now.timeIntervalSince(lastStart)
        let speed = seconds == 0 ? nil : NSNumber(value: Double(currentValue - self.lastValue) / seconds)

        let speedListener = NSNumber(value: Double(currentListenerValue - self.lastListenerValue) / seconds)

        self.lastValue = currentValue
        self.lastListenerValue = currentListenerValue

        if let speed = speed {
            print("---------------------------------------------------")
            print("Event speed      \(self.numberFormatter.string(from: speed)!) events/s")
            print("Listener Calls   \(self.numberFormatter.string(from: speedListener)!) calls/s")
            let cpuUsage = self.cpuUsage()
            maxCpuUsage = max(maxCpuUsage, cpuUsage)

            DispatchQueue.main.async {
                self.rateOfEventsCounter.text = speed.intValue > 1 ?
                "\(self.numberFormatter.string(from: speed)!) events/s" : " "
                self.rateOfListenersCounter.text = speedListener.intValue > 1 ?
                "\(self.numberFormatter.string(from: speedListener)!) calls/s" : " "

                if speed.intValue > 0 && speedListener.intValue > 0 {
                    let eventsIncall = speed.doubleValue / speedListener.doubleValue
                    self.numberOfEventsCounter.text = Int(eventsIncall) > 1 ?
                    "\(self.numberFormatter.string(from: NSNumber(value:eventsIncall))!) events" : " "
                } else {
                    self.numberOfEventsCounter.text = " "
                }

                self.currentCpuCounter.text = cpuUsage > 1.0 ? "\(self.numberFormatter.string(from: NSNumber(value:cpuUsage))!) %" : "0 %"
                self.peakCpuUsageCounter.text = self.maxCpuUsage > 1.0 ? "\(self.numberFormatter.string(from: NSNumber(value:self.maxCpuUsage))!) %" : "0 %"

            }
        }
    }

    fileprivate func cpuUsage() -> Double {
        var kr: kern_return_t
        var taskInfoCount: mach_msg_type_number_t

        taskInfoCount = mach_msg_type_number_t(TASK_INFO_MAX)
        var tinfo = [integer_t](repeating: 0, count: Int(taskInfoCount))

        kr = task_info(mach_task_self_, task_flavor_t(TASK_BASIC_INFO), &tinfo, &taskInfoCount)
        if kr != KERN_SUCCESS {
            return -1
        }

        var threadList: thread_act_array_t? = UnsafeMutablePointer(mutating: [thread_act_t]())
        var threadCount: mach_msg_type_number_t = 0
        defer {
            if let threadList = threadList {
                vm_deallocate(mach_task_self_, vm_address_t(UnsafePointer(threadList).pointee), vm_size_t(threadCount))
            }
        }

        kr = task_threads(mach_task_self_, &threadList, &threadCount)

        if kr != KERN_SUCCESS {
            return -1
        }

        var totCpu: Double = 0

        if let threadList = threadList {

            for jIndex in 0 ..< Int(threadCount) {
                var threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
                var thinfo = [integer_t](repeating: 0, count: Int(threadInfoCount))
                kr = thread_info(threadList[jIndex], thread_flavor_t(THREAD_BASIC_INFO),
                                 &thinfo, &threadInfoCount)
                if kr != KERN_SUCCESS {
                    return -1
                }

                let threadBasicInfo = convertThreadInfoToThreadBasicInfo(thinfo)

                if threadBasicInfo.flags != TH_FLAGS_IDLE {
                    totCpu += (Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE)) * 100.0
                }
            } // for each thread
        }

        return totCpu
    }

    fileprivate func convertThreadInfoToThreadBasicInfo(_ threadInfo: [integer_t]) -> thread_basic_info {
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

    func updateConnectButton() {
        self.connectButton.setTitle(self.isConnected ? "Disconnect" : "Connect", for: .normal)
    }

    @IBAction func connectTapped(_ sender: Any) {
        if isConnected {
            try? endpoint?.disconnect()
            subscription = nil
        } else {
            endpoint = try? DXEndpoint.builder().withRole(.feed).build()
            endpoint?.add(self)
            try? endpoint?.connect("localhost:6666")

            subscription = try? endpoint?.getFeed()?.createSubscription(.timeAndSale)
            profileSubscription = try? endpoint?.getFeed()?.createSubscription(.profile)
            subscription?.add(self)
            profileSubscription?.add(self)

            try? subscription?.addSymbols(symbols)
            try? profileSubscription?.addSymbols(symbols)
        }
    }
}

extension PerfTestViewController: DXEndpointObserver {
    func endpointDidChangeState(old: DxFeedSwiftFramework.DXEndpointState, new: DxFeedSwiftFramework.DXEndpointState) {
        DispatchQueue.main.async {
            self.isConnected = new == .connected
            self.updateConnectButton()

            self.connectionStatusLabel.text = new.convetToString()
        }
    }
}

extension PerfTestViewController: DXEventListener {
    func receiveEvents(_ events: [DxFeedSwiftFramework.MarketEvent]) {
        let count = events.count
        counter.add(Int64(count))
        counterListener.add(1)

        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            events.forEach { self.blackHoleInt ^= $0.eventTime }
        }
    }
}
