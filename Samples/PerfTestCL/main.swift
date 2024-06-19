//
//  main.swift
//  SwiftTestCLI
//
//  Created by Aleksey Kosylo on 20.02.2023.
//

import Foundation
import DXFeedFramework
var arguments: [String]
do {
    arguments = try ArgumentParser().parse(ProcessInfo.processInfo.arguments, numberOfPossibleArguments: 3)
} catch {
    print(
"""

Connects to the specified address(es) and calculates performance counters (events per second, cpu usage, etc).

Usage:
  path_to_app <address> <types> <symbols>

Where:

  address (pos. 0)       Required. The address(es) to connect to retrieve data (see "Help address").
                         For Token-Based Authorization, use the following format: "<address>:<port>[login=entitle:<token>]".
  types (pos. 1)         Required. Comma-separated list of dxfeed event types (e.g. Quote, TimeAndSale).
  symbols (pos. 2)       Required. Comma-separated list of symbol names to get events for (e.g. "IBM, AAPL, MSFT").
"""
    )
    print(error)

    exit(1)
}
let address = arguments[0]
let types = arguments[1]
let symbols = arguments[2]

let listener = EventListener(name: "count_listener")
let endpoint = try? DXEndpoint.builder().withRole(.feed).build()
_ = try? endpoint?.connect(address)

var subscriptions = [DXFeedSubcription]()
types.split(separator: ",").forEach { str in
    let subscription = try? endpoint?.getFeed()?.createSubscription(EventCode(string: String(str)))
    try? subscription?.add(observer: listener)
    try? subscription?.addSymbols(symbols)
    if let subscription = subscription {
        subscriptions.append(subscription)
    }
}

var startTime = Date.now
var lastValue: Int64 = 0
var lastListenerValue: Int64 = 0

let numberFormatter = NumberFormatter()
numberFormatter.numberStyle = .decimal

DispatchQueue.global(qos: .background).async {
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            let lastStart = startTime
            let currentValue = listener.counter.value
            let currentListenerValue = listener.counterListener.value
            startTime = Date.now
            let seconds = Date.now.timeIntervalSince(lastStart)
            let speed = seconds == 0 ? nil : NSNumber(value: Double(currentValue - lastValue) / seconds)
            let speedListener = seconds == 0 ? nil :
            NSNumber(value: Double(currentListenerValue - lastListenerValue) / seconds)

            lastValue = currentValue
            lastListenerValue = currentListenerValue
            if let speed = speed, let speedListener = speedListener {
                let everageNumberOfEvents = speedListener.intValue == 0 ? "" :
                numberFormatter.string(from: NSNumber(value: round(speed.floatValue/speedListener.floatValue)))!
                let result =
"""
    Event speed                : \(numberFormatter.string(from: speed)!) per/sec
    Listener speed             : \(numberFormatter.string(from: speedListener)!) per/sec
    Average Number of Events   : \(everageNumberOfEvents)
---------------------------------------------------
"""
                print(result)
            }
        }
        RunLoop.current.run()
}
// Calculate till input new line
_ = readLine()
