//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import DXFeedFramework

private class Counter {
    private(set) var value: Int64 = 0
    func add (_ amount: Int64) {
        OSAtomicAdd64(amount, &value)
    }
}

struct LatencyMetrics {
    let rateOfEvent: NSNumber
    let min: NSNumber
    let max: NSNumber
    let mean: NSNumber
    let percentile: NSNumber
    let sampleSize: NSNumber
    let measureInterval: NSNumber
    let stdDev: NSNumber
    let error: NSNumber
    let rateOfSymbols: NSNumber
    let currentTime: TimeInterval
    let cpuUsage: NSNumber
}

private class ConcurrentArray<T>: CustomStringConvertible {
    private var array: [T]
    private let accessQueue = DispatchQueue(label: "com.dxfeed.array_queue", attributes: .concurrent)

    public init(_ array: [T] = []) {
        self.array = array
    }

    public var description: String {
        return reader { $0.description }
    }

    public subscript(index: Int) -> T {
        get { reader { $0[index] } }
        set { writer { $0[index] = newValue } }
    }

    public var count: Int {
        reader { $0.count }
    }

    public func append(newElement: T) {
        writer { $0.append(newElement) }
    }

    public func append(newElements: [T]) {
        writer { $0.append(contentsOf: newElements) }
    }

    public func removeAll() {
        writer { $0.removeAll() }
    }

    public func removeAll(where shouldBeRemoved: @escaping (T) throws -> Bool) rethrows {
        writer { try? $0.removeAll(where: shouldBeRemoved) }
    }

    public func reader<U>(_ block: ([T]) throws -> U) rethrows -> U {
        try accessQueue.sync { try block(array) }
    }

    public func writer(_ block: @escaping (inout [T]) -> Void) {
        accessQueue.async(flags: .barrier) { block(&self.array) }
    }
}

private class ConcurrentSet<T>: CustomStringConvertible where T: Hashable {
    private var set = Set<T>()
    private let accessQueue = DispatchQueue(label: "com.dxfeed.set_queue", attributes: .concurrent)

    public init(_ set: Set<T> = Set<T>()) {
        self.set = set
    }

    public var description: String {
        return reader { $0.description }
    }

    public var count: Int {
        reader { $0.count }
    }

    public func insert(_ newMember: T) {
        writer { $0.insert(newMember) }
    }

    public func remove(_ member: T) {
        writer { $0.remove(member) }
    }

    public func remove(at position: Set<T>.Index) {
        writer { $0.remove(at: position) }
    }
    public func removeAll() {
        writer { $0.removeAll() }
    }

    public func reader<U>(_ block: (Set<T>) throws -> U) rethrows -> U {
        try accessQueue.sync { try block(set) }
    }

    public func writer(_ block: @escaping (inout Set<T>) -> Void) {
        accessQueue.async(flags: .barrier) { block(&self.set) }
    }
}

class LatencyDiagnostic {
    private var absoluteStartTime: Date?
    private var startTime = Date.now
    private var deltas = ConcurrentArray<Int64>()
    private var symbols = ConcurrentSet<String>()
    private var usageStats = UsageStats()

    func addDeltas(_ delta: Int64) {
        self.deltas.append(newElement: delta)
    }

    func addSymbol(_ symbol: String) {
        self.symbols.insert(symbol)
    }

    func getMetrics() -> LatencyMetrics {
        var currentDeltas = [Int64]()
        self.deltas.reader { values in
            currentDeltas = values
        }
        var currentSymbols = [String]()
        symbols.reader { symbols in
            currentSymbols = Array(symbols)
        }
        self.deltas.removeAll()
        self.symbols.removeAll()
        let lastStart = self.startTime
        self.startTime = Date.now
        if absoluteStartTime == nil {
            absoluteStartTime = self.startTime
        }
        let seconds = self.startTime.timeIntervalSince(lastStart)
        return LatencyDiagnostic.createMetrics(currentDeltas,
                                               currentSymbols,
                                               seconds,
                                               startTime.timeIntervalSince(absoluteStartTime ?? startTime),
                                               usageStats.cpuUsage)
    }

    private static func createMetrics(_ currentDeltas: [Int64],
                                      _ currentSymbols: [String],
                                      _ seconds: TimeInterval,
                                      _ currentTime: TimeInterval,
                                      _ cpuUsage: Double) -> LatencyMetrics {
        let min = currentDeltas.min() ?? 0
        let max = currentDeltas.max() ?? 0
        let mean = calculateMean(currentDeltas)

        let speed = seconds == 0 ? 0 : Double(currentDeltas.count) / seconds
        let percentile = !currentDeltas.isEmpty ? calculatePercentile(currentDeltas, excelPercentile: 0.99) : 0
        let stdDev = calculateStdDev(currentDeltas)
        let error = calculateError(currentDeltas, stdDev: stdDev)
        return LatencyMetrics(rateOfEvent: NSNumber(value: speed),
                              min: NSNumber(value: min),
                              max: NSNumber(value: max),
                              mean: NSNumber(value: mean),
                              percentile: NSNumber(value: percentile),
                              sampleSize: NSNumber(value: currentDeltas.count),
                              measureInterval: NSNumber(value: seconds),
                              stdDev: NSNumber(value: stdDev),
                              error: NSNumber(value: error.isNaN ? 0 : error),
                              rateOfSymbols: NSNumber(value: currentSymbols.count),
                              currentTime: currentTime,
        cpuUsage: NSNumber(value: cpuUsage))
    }

    private static func calculatePercentile(_ deltas: [Int64], excelPercentile: Double) -> Double {
        let deltas = deltas.sorted()
        let deltasCount = deltas.count
        let nVar = (Double(deltasCount - 1) * excelPercentile) + 1
        if nVar == 1 {
            return Double(deltas.first!)
        }
        if nVar == Double(deltasCount) {
            return Double(deltas.last!)
        }
        let kIndex = Int(nVar)
        let dIndex = nVar - Double(kIndex)
        return Double(deltas[kIndex - 1]) + (dIndex * Double((deltas[kIndex] - deltas[kIndex - 1])))
    }

    private static func calculateMean(_ deltas: [Int64]) -> Double {
        let sumArray = deltas.reduce(0, +)
        let mean = Double(sumArray) / Double(deltas.count > 0 ? deltas.count : 1)
        return mean
    }

    private static func calculateStdDev(_ deltas: [Int64]) -> Double {
        var stdDev = 0.0
        var count = deltas.count
        if count <= 1 {
            return stdDev
        }
        count -= 1
        let avg = calculateMean(deltas)
        let sum = deltas.reduce(0.0) { partialResult, value in
            partialResult + pow(Double(value) - avg, 2)
        }
        stdDev = sqrt(sum / Double(count))
        return stdDev
    }

    private static func calculateError(_ deltas: [Int64], stdDev: Double) -> Double {
        let count = Double(deltas.count)
        return stdDev / sqrt(count)
    }

    func cleanTime() {
        absoluteStartTime = nil
    }

    func updateCpuUsage() {
        usageStats.updateCpuUsage()
    }
}
