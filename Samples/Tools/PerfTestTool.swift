//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import DXFeedFramework

class PerfTestTool: ToolsCommand {
    var isTools: Bool = true
    var cmd: String = "PerfTest"
    var shortDescription: String = "Connects to specified address and calculates performance counters."
    var fullDescription: String =
    """
    Connects to the specified address(es) and calculates performance counters (events per second, cpu usage, etc).

    Usage:
    path_to_app <address> <types> <symbols> [<options>]

    Where:

    address (pos. 0)  Required. The address(es) to connect to retrieve data (see "Help address").
                    For Token-Based Authorization, use the following format: "<address>:<port>[login=entitle:<token>]".
    types (pos. 1)    Required. Comma-separated list of dxfeed event types (e.g. Quote, TimeAndSale).
    symbols (pos. 2)  Required. Comma-separated list of symbol names to get events for (e.g. "IBM, AAPL, MSFT").
    --force-stream    Enforces a streaming contract for subscription. The StreamFeed role is used instead of Feed.
    """

    private lazy var arguments: Arguments = {
        do {
            let arguments = try Arguments(ProcessInfo.processInfo.arguments, requiredNumberOfArguments: 4)
            return arguments
        } catch {
            print(fullDescription)
            exit(0)
        }
    }()

    var subscription = Subscription()
    func execute() {
        let address = arguments[1]
        arguments.properties.forEach { key, value in
            try? SystemProperty.setProperty(key, value)
        }
        let listener = PerfTestEventListener()

        let symbols = arguments.parseSymbols()
        let types = arguments.parseTypes(at: 2)
        subscription.createSubscription(address: address,
                                        symbols: symbols,
                                        types: types,
                                        role: arguments.isForceStream ? .streamFeed : .feed,
                                        listeners: [listener],
                                        properties: arguments.properties,
                                        time: nil)

        let timer = DXFTimer(timeInterval: 2)
        let printers = [SamplePerformancePrinter(),
                        MonitoringStatsPrinter(numberOfSubscription: symbols.count * types.count,
                                               address: address)] as [PerformanceMetricsPrinter]
        timer.eventHandler = {
            let metrics = listener.metrics()
            listener.updateCpuUsage()
            printers.forEach({ printer in
                printer.update(metrics)
            })
        }
        timer.resume()
        // Calculate till input new line
        _ = readLine()

    }

}
