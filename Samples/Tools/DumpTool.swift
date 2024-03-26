//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import DXFeedFramework

class DumpTool: ToolsCommand {
    var isTools: Bool = true
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
               If <types> is not specified, creates a subscription for all available event types.
    <symbol>   is comma-separated list of symbol names to get events for (e.g. ""IBM,AAPL,MSFT"").
               for Candle event specify symbol with aggregation like in ""AAPL{{=d}}""
               If <symbol> is not specified, the wildcard symbol is used.
    Usage:
        Dump <address> [<options>]
        Dump <address> <types> [<options>]
        Dump <address> <types> <symbols> [<options>]

    Sample: Dump demo.dxfeed.com:7300 quote AAPL,IBM,ETH/USD:GDAX -t "tape_test.txt[format=text]"
    Sample: Dump tapeK2.tape[speed=max] all all -q -t ios_tapeK2.tape
    Sample: Dump tapeK2.tape[speed=max] -q -t ios_tapeK2.tape

    """
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

    private var listeners = [EventListener]()

    fileprivate func close(_ inputEndpoint: DXEndpoint, _ outputEndpoint: DXEndpoint?) throws {
        try inputEndpoint.awaitNotConnected()
        try inputEndpoint.closeAndAwaitTermination()
        try outputEndpoint?.awaitProcessed()
        try outputEndpoint?.closeAndAwaitTermination()
    }

    func execute() {
        let address = arguments[1]
        let symbols = arguments.parseSymbols()

        isQuite = arguments.isQuite

        if !isQuite {
            listeners.append(EventListener(callback: { events in
                events.forEach { event in
                    print(event.toString())
                }
            }))
        }
        do {
            try arguments.properties.forEach { key, value in
                try SystemProperty.setProperty(key, value)
            }
            let inputEndpoint = try DXEndpoint
                .builder()
                .withRole(.streamFeed)
                .withProperty(DXEndpoint.Property.wildcardEnable.rawValue, "true")
                .withProperties(arguments.properties)
                .withName("DumpTool")
                .build()

            let eventTypes = arguments.parseTypes(at: 2)
            let subscription = try inputEndpoint.getFeed()?.createSubscription(eventTypes)
            var outputEndpoint: DXEndpoint?

            if let tapeFile = arguments.tape {
                outputEndpoint = try DXEndpoint
                    .builder()
                    .withRole(.streamPublisher)
                    .withProperty(DXEndpoint.Property.wildcardEnable.rawValue, "true")
                    .withName("DumpTool")
                    .build()
                try outputEndpoint?.connect("tape:\(tapeFile)")
                publisher = outputEndpoint?.getPublisher()
                listeners.append(EventListener(callback: { [weak self] events in
                    do {
                        _ = try self?.publisher?.publish(events: events)
                    } catch {
                        print("Connect tool publish error: \(error)")
                    }
                }))
            }
            try listeners.forEach { listener in
                try subscription?.add(listener: listener)

            }
            try subscription?.addSymbols(symbols)

            try inputEndpoint.connect(address)

            try close(inputEndpoint, outputEndpoint)
        } catch {
            print("Dump tool error: \(error)")
        }
    }
}
