//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation

class MonitoringStatsPrinter: PerformanceMetricsPrinter, LatencyPrinter {
    let numberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    let cpuFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    let dateFormat = {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyMMdd HHmmss.SSS"
        return dateFormat
    }()
    let numberOfSubscription: Int
    let address: String

    init(numberOfSubscription: Int, address: String) {
        self.numberOfSubscription = numberOfSubscription
        self.address = address
    }

    // swiftlint:disable line_length
    func update(_ metrics: PerformanceMetrics) {
        let rateOfEventsCounter = "\(numberFormatter.string(from: metrics.rateOfEvent)!)"
        let currentCpuCounter = "\(cpuFormatter.string(from: metrics.cpuUsage)!)%"
        let result = """
\(dateFormat.string(from: Date())) {SubscriptionEndpoint} Subscription: \(numberOfSubscription); Storage: ???; Buffer: 0; Read: ??? Bps (data \(rateOfEventsCounter) rps lag ??? us); Write: ??? Bps; rtt ??? us; TOP bytes read Quote: ???%; CPU: \(currentCpuCounter)
    ClientSocket-Distributor \(address) [1] Read: ??? Bps (data \(rateOfEventsCounter) rps lag ??? us); Write: ??? Bps; rtt ??? us; TOP bytes read Quote: ???%
"""
        print(result)
        print("--------------------------------------------------------------------")
    }

    func update(_ metrics: LatencyMetrics) {
        let rateOfEventsCounter = "\(numberFormatter.string(from: metrics.rateOfEvent)!)"
        let latency = "\(numberFormatter.string(from: NSNumber(value: metrics.mean.doubleValue * 1000))!)"
        let currentCpuCounter = "\(cpuFormatter.string(from: metrics.cpuUsage)!)%"
        let result = """
\(dateFormat.string(from: Date())) {SubscriptionEndpoint} Subscription: \(numberOfSubscription); Storage: ???; Buffer: 0; Read: ??? Bps (data \(rateOfEventsCounter) rps lag \(latency) us); Write: ??? Bps; rtt ??? us; TOP bytes read Quote: ???%; CPU: \(currentCpuCounter)
    ClientSocket-Distributor \(address) [1] Read: ??? Bps (data \(rateOfEventsCounter) rps lag \(latency) us); Write: ??? Bps; rtt ??? us; TOP bytes read Quote: ???%
"""
        print(result)
        print("--------------------------------------------------------------------")
    }
    // swiftlint:enable line_length

}
