//
//  ConnectCommand.swift
//  Tools
//
//  Created by Aleksey Kosylo on 27.09.23.
//

import Foundation
import DXFeedFramework

class ConnectTool: ToolsCommand {
    var isTools: Bool = true
    var cmd = "Connect"
    var shortDescription = "Connects to specified address(es)."

    var fullDescription  =
"""
Connect
=======

Usage:
  Connect <address> <types> <symbols> [-f <time>]

Where:
    address - The address to connect to retrieve data (remote host or local tape file).
              To pass an authorization token, add to the address: ""[login=entitle:<token>]"",
              e.g.: demo.dxfeed.com:7300[login=entitle:<token>]
    types   - Is comma-separated list of dxfeed event types ({eventTypeNames}).
    symbol  - Is comma-separated list of symbol names to get events for (e.g. ""IBM,AAPL,MSFT"").
              for Candle event specify symbol with aggregation like in ""AAPL{{=d}}""
    time    - Is from-time for history subscription in standard formats.
              Same examples of valid from-time:
                  20070101-123456
                  20070101-123456.123
                  2005-12-31 21:00:00
                  2005-12-31 21:00:00.123+03:00
                  2005-12-31 21:00:00.123+0400
                  2007-11-02Z
                  123456789 - value-in-milliseconds

"""

    var subscription = Subscription()
    var outputEndpoint: DXEndpoint?

    var publisher: DXPublisher?
    var isQuite = false

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
        isQuite = arguments.isQuite

        arguments.properties.forEach { key, value in
            try? SystemProperty.setProperty(key, value)
        }

        if let tapeFile = arguments.tape {
            outputEndpoint = try? DXEndpoint
                .builder()
                .withRole(.streamPublisher)
                .withProperty(DXEndpoint.Property.wildcardEnable.rawValue, "true")
                .withProperties(arguments.properties)
                .withName("ConnectTool")
                .build()
            _ = try? outputEndpoint?.connect("tape:\(tapeFile)")
            publisher = outputEndpoint?.getPublisher()
        }
        subscription.createSubscription(address: arguments[1],
                                        symbols: arguments.parseSymbols(at: 3),
                                        types: arguments.parseTypes(at: 2),
                                        listener: self,
                                        properties: arguments.properties,
                                        time: arguments.time,
                                        source: arguments.source)

        // Print till input new line
        _ = readLine()
    }
}

extension ConnectTool: Hashable {
    static func == (lhs: ConnectTool, rhs: ConnectTool) -> Bool {
        return lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(stringReference(self))
    }
}

extension ConnectTool: DXEventListener {
    func receiveEvents(_ events: [DXFeedFramework.MarketEvent]) {
        do {
            if !isQuite {
                events.forEach { event in
                    print(event.toString())
                }
            }
            _ = try publisher?.publish(events: events)
        } catch {
            print("Connect tool publish error: \(error)")
        }
    }
}
