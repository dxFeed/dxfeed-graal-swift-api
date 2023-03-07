//
//  main.swift
//  PerfTest
//
//  Created by Aleksey Kosylo on 02.03.2023.
//

import Foundation
import DxFeedFramework

class SubscriptionListener: DXFSubscriptionListener {
    class Counter {
        private (set) var value : Int64 = 0
        func add (_ amount: Int64) {
            OSAtomicAdd64(amount, &value)
        }
    }
    var counter = Counter()
    var counterListener = Counter()
    func receivedEvents(_ events: [DXFEvent]!) {
        let count = events.count
        counterListener.add(1)
        counter.add(Int64(count))
    }
}

struct Parameters {
    let address: String
    let type: [DXFEventType]
    let symbol: [String]
}

if CommandLine.arguments.count != 4 {
    print("""
Usage: FeedTestCLI <host:port> <event> <symbol>
where
    host:port  - The address of dxFeed server demo.dxfeed.com:7300
    event      - One of the {Quote,TimeSale}
    symbol     - IBM, MSFT, ETH/USD:GDAX,  ...

""")
    exit(1)
}


let args = CommandLine.arguments

let types = args[2].split(separator: ",").map { str in
    switch str.lowercased() {
    case "quote":
        return DXFEventType.quote
    case "timesale":
        return DXFEventType.timeSale
    default:
        return DXFEventType.undefined
    }
}
let params = Parameters(address: args[1], type: types, symbol: args[3].split(separator: ",").map({ String($0) }))
print(params)
print("*****Press enter to stop****")

//using nullable var for checking deallocations
var env: DXFEnvironment? = DXFEnvironment()
var connection:DXFConnection? = DXFConnection(env!, address: params.address)
connection?.connect()
var feed:DXFFeed? = DXFFeed(connection!, env: env!)
var subscription: DXFSubscription? = DXFSubscription(env!, feed: feed!, type: types.first!)
let listener = SubscriptionListener()
subscription?.add(listener)
subscription?.subscribe(params.symbol.first!)

var timer: Timer?

DispatchQueue.global(qos: .background).async {
    var startTime = Date.now
    var lastValue: Int64 = 0
    var lastListenerValue: Int64 = 0

    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
        let lastStart = startTime
        let currentValue = listener.counter.value
        let currentListenerValue = listener.counterListener.value
        startTime = Date.now
        let seconds = Date.now.timeIntervalSince(lastStart)
        let speed = NSNumber(value: Double(currentValue - lastValue) / seconds)
        let speedListener = NSNumber(value: Double(currentListenerValue - lastListenerValue) / seconds)

        lastValue = currentValue
        lastListenerValue = currentListenerValue
       
        print("---------------------------------------------------")
        print("     Events                       \(numberFormatter.string(from: speed)!) per/sec")
        print("     Listener Calls               \(numberFormatter.string(from: speedListener)!) per/sec")
        if (speedListener.intValue != 0) {
            print("     Average Number of Events     \(numberFormatter.string(from: NSNumber(value: speed.intValue/speedListener.intValue))!)")
        }
    }
    RunLoop.current.run()
}

_ = readLine()
print("*********dealloc*********")
timer?.invalidate()
timer = nil
subscription = nil
feed = nil
connection = nil
env = nil
print("The app should have disconnected from \(params.address). Сheck above")
_ = readLine()
