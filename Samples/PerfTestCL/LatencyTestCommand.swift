//
//  LatencyTestCommand.swift
//  Tools
//
//  Created by Aleksey Kosylo on 29.09.23.
//

import Foundation

class LatencyTestCommand: ToolsCommand {
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
    """
    var subscription = Subscription()
    private lazy var arguments: Arguments = {
        do {
            let arguments = try Arguments(ProcessInfo.processInfo.arguments, requiredNumberOfArguments: 4)
            return arguments
        } catch {
            print(fullDescription)
            fatalError()
        }
    }()

    func execute() {
        let address = arguments[1]
        let types = arguments.parseTypes(at: 2)

        let listener = LatencyEventListener()

        subscription.createSubscription(address: address,
                                        symbols: arguments.parseSymbols(at: 3),
                                        types: types,
                                        listener: listener,
                                        properties: arguments.properties,
                                        time: nil)

        let timer = DXFTimer(timeInterval: 2)
        let printer = LatencyMetricsPrinter()
        timer.eventHandler = {
            let metrics = listener.metrics()
            printer.update(metrics)
        }
        timer.resume()
        // Calculate till input new line
        _ = readLine()

    }
}
