//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import DXFeedFramework

class LatencyTestTool: ToolsCommand {
    var isTools: Bool = true
    var cmd = "LatencyTest"

    var shortDescription = "Connects to the specified address(es) and calculates latency."

    var fullDescription: String =
    """
    Connects to the specified address(es) and calculates latency.

    Usage:
      LatencyTest <address> <types> <symbols> [<options>]

    Where:

      address (pos. 0)  Required. The address(es) to connect to retrieve data (see "Help address").
                    For Token-Based Authorization, use the following format: "<address>:<port>[login=entitle:<token>]".
      types (pos. 1)    Comma-separated list of dxfeed event types (e.g. Quote, TimeAndSale).
                        Use "all" for all available event types.
      symbols (pos. 2)  Comma-separated list of symbol names to get events for (e.g. "IBM, AAPL, MSFT").
                        Use "all" for wildcard subscription.
                        The "dxfeed.wildcard.enable" property must be set to true to enable wildcard subscription.
      --force-stream    Enforces a streaming contract for subscription. The StreamFeed role is used instead of Feed.

    """
    var subscription = Subscription()
    private lazy var arguments: Arguments = {
        do {
            let arguments = try Arguments(ProcessInfo.processInfo.arguments, requiredNumberOfArguments: 4)
            return arguments
        } catch {
            print(fullDescription)
            exit(0)
        }
    }()

    func execute() {
        let address = arguments[1]
        let types = arguments.parseTypes(at: 2)
        arguments.properties.forEach { key, value in
            try? SystemProperty.setProperty(key, value)
        }
        let listener = LatencyEventListener()
        let symbols = arguments.parseSymbols()

        subscription.createSubscription(address: address,
                                        symbols: symbols,
                                        types: types,
                                        role: arguments.isForceStream ? .streamFeed : .feed,
                                        listeners: [listener],
                                        properties: arguments.properties,
                                        time: nil)

        let timer = DXFTimer(timeInterval: 2)
        let printers: [LatencyPrinter] = [LatencyMetricsPrinter(),
                                          MonitoringStatsPrinter(numberOfSubscription: symbols.count * types.count,
                                                                 address: address)]
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
