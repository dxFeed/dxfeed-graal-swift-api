//
//  Diagnostic.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 14.06.23.
//

import Foundation
import DxFeedSwiftFramework

private class Counter {
    private (set) var value: Int64 = 0
    func add (_ amount: Int64) {
        OSAtomicAdd64(amount, &value)
    }
}

struct Metrics {
    let rateOfEvent: NSNumber
    let min: NSNumber
    let max: NSNumber
    let mean: NSNumber
}

class Diagnostic {
    private var startTime = Date.now

    private var counter = Counter()
    private var counterListener = Counter()

    private var lastValue: Int64 = 0
    private var lastListenerValue: Int64 = 0
    private var deltas = ConcurrentArray<UInt64>()

    func updateCounters(_ count: Int64) {
        counter.add(count)
        counterListener.add(1)
    }

    func addDeltas(_ deltas: [UInt64]) {
        self.deltas.append(newElements: deltas)
    }

    func getMetrics() -> Metrics {
        var currentDeltas = [UInt64]()
        self.deltas.reader { values in
            currentDeltas = values
        }
        self.deltas.removeAll()
        let min = currentDeltas.min() ?? 0
        let max = currentDeltas.max() ?? 0
        let sumArray = currentDeltas.reduce(0, +)
        let mean = sumArray / UInt64(currentDeltas.count > 0 ? currentDeltas.count : 1)
        let lastStart = self.startTime
        let currentValue = self.counter.value
        let currentListenerValue = self.counterListener.value

        self.startTime = Date.now
        let seconds = Date.now.timeIntervalSince(lastStart)
        let speed = seconds == 0 ? 0 : Double(currentDeltas.count) / seconds

        let speedListener =  Double(currentListenerValue - self.lastListenerValue) / seconds
        let eventsIncall = speed / speedListener

        self.lastValue = currentValue
        self.lastListenerValue = currentListenerValue
        return Metrics(rateOfEvent: NSNumber(value: speed), min: NSNumber(value: min), max: NSNumber(value: max), mean: NSNumber(value: mean))
    }
}
