//
//  LatencyMetricsPrinter.swift
//  PerfTestCL
//
//  Created by Aleksey Kosylo on 25.09.23.
//

import Foundation

class LatencyMetricsPrinter {
    let numberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    func update(_ metrics: LatencyMetrics) {
        let result = """
    Rate of events (avg)     : \(numberFormatter.string(from: metrics.rateOfEvent)!) (events/s)
    Rate of unique symbols   : \(numberFormatter.string(from: metrics.rateOfSymbols)!) (symbols/interval)
    Min                      : \(numberFormatter.string(from: metrics.min)!) (ms)
    Max                      : \(numberFormatter.string(from: metrics.max)!) (ms)
    99th percentile          : \(numberFormatter.string(from: metrics.percentile)!) (ms)
    Mean                     : \(numberFormatter.string(from: metrics.mean)!) (ms)
    StdDev                   : \(numberFormatter.string(from: metrics.stdDev)!) (ms)
    Error                    : \(numberFormatter.string(from: metrics.error)!) (ms)
    Sample size (N)          : \(numberFormatter.string(from: metrics.sampleSize)!) (events)
    Measurement interval     : \(numberFormatter.string(from: metrics.measureInterval)!) (s)
    Running time             : \(metrics.currentTime.stringFromTimeInterval())
"""
        print(result)
        print("---------------------------------------------------------")

    }
}
