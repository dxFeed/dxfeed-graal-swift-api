//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

class PerformanceMetricsPrinter {
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

    func update(_ metrics: PerformanceMetrics) {
        let rateOfEventsCounter = "\(numberFormatter.string(from: metrics.rateOfEvent)!) events/s"
        let rateOfListenersCounter = "\(numberFormatter.string(from: metrics.rateOfListeners)!) calls/s"
        var eventsIncall = 0.0
        if metrics.rateOfEvent.intValue > 0 && metrics.rateOfListeners.intValue > 0 {
            eventsIncall = metrics.rateOfEvent.doubleValue / metrics.rateOfListeners.doubleValue
        }
        let numberOfEventsCounter = "\(numberFormatter.string(from: NSNumber(value: eventsIncall))!) events"
        let currentCpuCounter = "\(cpuFormatter.string(from: metrics.cpuUsage)!) %"
        let peakCpuUsageCounter = "\(cpuFormatter.string(from: metrics.peakCpuUsage)!) %"
        let result = """
    Rate of events (avg)           : \(rateOfEventsCounter)
    Rate of listener calls         : \(rateOfListenersCounter)
    Number of events in call (avg) : \(numberOfEventsCounter)
    Current memory usage           : \(cpuFormatter.string(from: metrics.memmoryUsage)!) Mbyte
    Peak memory usage              : \(cpuFormatter.string(from: metrics.peakMemmoryUsage)!) Mbyte
    Current CPU usage              : \(currentCpuCounter)
    Peak CPU usage                 : \(peakCpuUsageCounter)
    Running time                   : \(metrics.currentTime.stringFromTimeInterval())
"""
        print(result)
        print("--------------------------------------------------------------------")
    }
}
