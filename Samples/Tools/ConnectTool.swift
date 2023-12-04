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
  Connect <address> <types> <symbols> [-f <time>] [<options>]

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
    --force-stream    Enforces a streaming contract for subscription. The StreamFeed role is used instead of Feed.


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
    private var listeners = [EventListener]()

    func execute() {
        isQuite = arguments.isQuite
        print(FileManager.default.currentDirectoryPath)
        arguments.properties.forEach { key, value in
            try? SystemProperty.setProperty(key, value)
        }
        if !isQuite {
            listeners.append(EventListener(callback: { events in
                events.forEach { event in
                    print(event.toString())
                }
            }))
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
            listeners.append(EventListener(callback: { [weak self] events in
                do {
                    _ = try self?.publisher?.publish(events: events)
                } catch {
                    print("Connect tool publish error: \(error)")
                }
            }))
        }

        subscription.createSubscription(address: arguments[1],
                                        symbols: arguments.parseSymbols(at: 3),
                                        types: arguments.parseTypes(at: 2),
                                        role: arguments.isForceStream ? .streamFeed : .feed,
                                        listeners: listeners,
                                        properties: arguments.properties,
                                        time: arguments.time,
                                        source: arguments.source)

        // Print till input new line
        _ = readLine()
    }

    func testConverTapeFile() throws {
        class Listener: DXEventListener, Hashable {

            static func == (lhs: Listener, rhs: Listener) -> Bool {
                lhs === rhs
            }

            func hash(into hasher: inout Hasher) {
                hasher.combine("\(self):\(stringReference(self))")
            }
            var callback: ([MarketEvent]) -> Void = { _ in }

            func receiveEvents(_ events: [MarketEvent]) {
                self.callback(events)
            }

            init(overrides: (Listener) -> Listener) {
                _ = overrides(self)
            }
        }


        // Determine input and output tapes and specify appropriate configuration parameters.
        let inputAddress = "file:/Users/akosylo/Projects/tapeK2.tape[readAs=stream_data,speed=max]"
        let outputAddress = "tape:/Users/akosylo/Projects/tapeK21.tape[saveAs=stream_data,format=text]"

        // Create input endpoint configured for tape reading.
        let inputEndpoint = try DXEndpoint.builder()
            .withRole(.streamFeed) // Prevents event conflation and loss due to buffer overflow.
            .withProperty(DXEndpoint.Property.wildcardEnable.rawValue, "true") // Enables wildcard subscription.
            .withProperty(DXEndpoint.Property.eventTime.rawValue, "true") // Use provided event times.
            .build()

        // Create output endpoint configured for tape writing.
        var outputEndpoint = try DXEndpoint.builder()
            .withRole(.streamPublisher) // Prevents event conflation and loss due to buffer overflow.
            .withProperty(DXEndpoint.Property.wildcardEnable.rawValue, "true") // Enables wildcard subscription.
            .withProperty(DXEndpoint.Property.eventTime.rawValue, "true") // Use provided event times.
            .build()

        // Create and link event processor for all types of events.
        // Note: Set of processed event types could be limited if needed.
        let eventTypes: [EventCode] = EventCode.allCases.compactMap { eventCode in
            if EventCode.unsupported().contains(eventCode) {
                return nil
            } else {
                return eventCode
            }
        }

        let feed = inputEndpoint.getFeed()
        let subscription = try feed?.createSubscription(eventTypes)

        let listener = Listener { anonymCl in
            anonymCl.callback = { events in
                // Here event processing occurs. Events could be modified, removed, or new events added.
                // For example, the below code adds 1 hour to event times:
                // foreach (var e in events)
                // {
                //     e.EventTime += 3600_000
                // }

                // Publish processed events
//                let publisher = outputEndpoint.getPublisher()
//                try? publisher?.publish(events: events)
            }
            return anonymCl
        }

        try subscription?.add(listener: listener)

        // Subscribe to all symbols.
        // Note: Set of processed symbols could be limited if needed.
        try subscription?.addSymbols(WildcardSymbol.all)

        // Connect output endpoint and start output tape writing BEFORE starting input tape reading.
        try outputEndpoint.connect(outputAddress)
        // Connect input endpoint and start input tape reading AFTER starting output tape writing.
        try inputEndpoint.connect(inputAddress)

        // Wait until all data is read and processed, and then gracefully close input endpoint.
        try inputEndpoint.awaitNotConnected()
        try inputEndpoint.closeAndAWaitTermination()

        // Wait until all data is processed and written, and then gracefully close output endpoint.
        try outputEndpoint.awaitProcessed()
        try outputEndpoint.closeAndAWaitTermination()
    }
}
