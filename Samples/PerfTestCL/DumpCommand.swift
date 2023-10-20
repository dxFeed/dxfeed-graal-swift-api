//
//  DumpCommand.swift
//  Tools
//
//  Created by Aleksey Kosylo on 19.10.23.
//

import Foundation
import DXFeedFramework

class DumpCommand: ToolsCommand {
    var cmd: String = "Dump"

    var shortDescription = "Dumps all events received from address."

    var fullDescription =
    """
    Dumps all events received from address.
    Enforces a streaming contract for subscription. A wildcard enabled by default.
    This was designed to receive data from a file.
    Usage: Dump <address> <types> <symbols> [<options>]

    Where:
    <address>  is a URL to Schedule API defaults file
    <types>    is comma-separated list of dxfeed event types ({eventTypeNames}).
    <symbol>   is comma-separated list of symbol names to get events for (e.g. ""IBM,AAPL,MSFT"").
              for Candle event specify symbol with aggregation like in ""AAPL{{=d}}""

    sample: Dump demo.dxfeed.com:7300 quote AAPL,IBM,ETH/USD:GDAX -t "tape_test.txt[format=text]"
    """
    var publisher: DXPublisher?
    var isQuite = false

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
        let types = arguments[2]
        let symbols = arguments.parseSymbols(at: 3)

        isQuite = arguments.isQuite

        do {
            let inputEndpoint = try DXEndpoint
                .builder()
                .withRole(.streamFeed)
                .withProperty(DXEndpoint.Property.wildcardEnable.rawValue, "true")
                .withProperties(arguments.properties)
                .withName("DumpTool")
                .build()

            let eventTypes = types.split(separator: ",").compactMap { str in
                return EventCode(string: String(str))
            }
            let subscription = try inputEndpoint.getFeed()?.createSubscription(eventTypes)
            var outputEndpoint: DXEndpoint?

            if let tapeFile = arguments.tape {
                outputEndpoint = try DXEndpoint
                    .builder()
                    .withRole(.publisher)
                    .withProperty(DXEndpoint.Property.wildcardEnable.rawValue, "true")
                    .withName("DumpTool")
                    .build()
                try outputEndpoint?.connect("tape:\(tapeFile)")
                publisher = outputEndpoint?.getPublisher()
            }

            try subscription?.add(observer: self)

            try subscription?.addSymbols(symbols)

            try inputEndpoint.connect(address)

            try inputEndpoint.awaitNotConnected()
            try inputEndpoint.closeAndAWaitTermination()

            try outputEndpoint?.awaitNotConnected()
            try outputEndpoint?.closeAndAWaitTermination()
        } catch {
            print("Dump tool error: \(error)")
        }
    }
}

extension DumpCommand: Hashable {
    static func == (lhs: DumpCommand, rhs: DumpCommand) -> Bool {
        return lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(stringReference(self))
    }
}

extension DumpCommand: DXEventListener {
    func receiveEvents(_ events: [DXFeedFramework.MarketEvent]) {
        do {
            if !isQuite {
                print(events)
            }
            try publisher?.publish(events: events)
        } catch {
            print("Dump tool publish error: \(error)")
        }
    }
}
