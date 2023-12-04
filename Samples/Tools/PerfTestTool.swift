//
//  PerfTestTool.swift
//  Tools
//
//  Created by Aleksey Kosylo on 26.09.23.
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

        let listener = PerfTestEventListener()

        subscription.createSubscription(address: address,
                                        symbols: arguments.parseSymbols(at: 3),
                                        types: arguments.parseTypes(at: 2),
                                        role: arguments.isForceStream ? .streamFeed : .feed,
                                        listeners: [listener],
                                        properties: arguments.properties,
                                        time: nil)

        let timer = DXFTimer(timeInterval: 2)
        let printer = PerformanceMetricsPrinter()
        timer.eventHandler = {
            let metrics = listener.metrics()
            listener.updateCpuUsage()
            printer.update(metrics)
        }
        timer.resume()
        // Calculate till input new line
        _ = readLine()

    }

}
