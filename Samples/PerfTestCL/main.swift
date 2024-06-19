//
//  main.swift
//  SwiftTestCLI
//
//  Created by Aleksey Kosylo on 20.02.2023.
//

import Foundation
import DXFeedFramework

let listener = EventListener(name: "count_listener")
let endpoint = try? DXEndpoint.builder().withRole(.feed).build()
_ = try? endpoint?.connect("akosylo-mac.local:6666")

let subscription = try? endpoint?.getFeed()?.createSubscription(.timeAndSale)
try? subscription?.add(observer: listener)
try? subscription?.addSymbols("YQKNT")

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
