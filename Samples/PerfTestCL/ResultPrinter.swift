//
//  ResultPrinter.swift
//  PerfTestCL
//
//  Created by Aleksey Kosylo on 25.09.23.
//

import Foundation

class ResultPrinter {
    let numberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    let cpuFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    let soureTitles = ["Rate of events (avg)",
                       "Rate of listener calls",
                       "Number of events in call (avg)",
                       "Current memory usage",
                       "Peak memory usage",
                       "Current CPU usage",
                       "Peak CPU usage",
                       "Running time"]

    var dataSource = [String: String]()

    lazy var maxSize =
    {
        (soureTitles.max { val1, val2 in
        val1.count < val2.count
        }?.count ?? 20) + 3
    }()

    func update(_ metrics: Metrics) {
        let rateOfEventsCounter = "\(numberFormatter.string(from: metrics.rateOfEvent)!) events/s"
        let rateOfListenersCounter = "\(numberFormatter.string(from: metrics.rateOfListeners)!) calls/s"
        var eventsIncall = 0.0
        if metrics.rateOfEvent.intValue > 0 && metrics.rateOfListeners.intValue > 0 {
            eventsIncall = metrics.rateOfEvent.doubleValue / metrics.rateOfListeners.doubleValue
        }
        let numberOfEventsCounter = "\(numberFormatter.string(from: NSNumber(value: eventsIncall))!) events"
        let currentCpuCounter = "\(cpuFormatter.string(from: metrics.cpuUsage)!) %"
        let peakCpuUsageCounter = "\(cpuFormatter.string(from: metrics.peakCpuUsage)!) %"
        dataSource = [
            "Rate of events (avg)": rateOfEventsCounter,
            "Rate of listener calls": rateOfListenersCounter,
            "Number of events in call (avg)": numberOfEventsCounter,
            "Current memory usage": "\(cpuFormatter.string(from: metrics.memmoryUsage)!) Mbyte",
            "Peak memory usage": "\(cpuFormatter.string(from: metrics.peakMemmoryUsage)!) Mbyte",
            "Current CPU usage": currentCpuCounter,
            "Peak CPU usage": peakCpuUsageCounter,
            "Running time": "\(metrics.currentTime.stringFromTimeInterval())"
        ]

        print("--------------------------------------------------------------------")
        soureTitles.forEach { title  in
            let value = dataSource[title]
            let spaces = maxSize - title.count
            print("  \(title + String(repeating: " ", count: spaces)): \(value ?? "")")
        }
    }
}