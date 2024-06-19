//
//  DXCandleTests.swift
//  DXFeedFrameworkTests
//
//  Created by Aleksey Kosylo on 13.07.23.
//

import XCTest
@testable import DXFeedFramework

final class DXCandleTests: XCTestCase {

    func testFetchingCandles() throws {
        let code = EventCode.candle
        var endpoint: DXEndpoint? = try DXEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        try endpoint?.connect("demo.dxfeed.com:7300")
        let subscription = try endpoint?.getFeed()?.createSubscription(code)
        let receivedEventExp = expectation(description: "Received events \(code)")
        subscription?.add(AnonymousClass { anonymCl in
            anonymCl.callback = { events in
                if events.count > 0 {
                    events.forEach { event in
                        print(event)
                    }
                    receivedEventExp.fulfill()
                }
            }
            return anonymCl
        })
        try subscription?.addSymbols(TimeSeriesSubscriptionSymbol(symbol: "AAPL{=2d}", fromTime: 0))
        wait(for: [receivedEventExp], timeout: 10)
        try? endpoint?.disconnect()
        endpoint = nil
        let sec = 5
        _ = XCTWaiter.wait(for: [expectation(description: "\(sec) seconds waiting")], timeout: TimeInterval(sec))



    }

    func testTest123() throws {
        let string = "Hello, world sad lo ! lo"
        let range = 0...10
        print(range.first!) // 0
        print(range.last!) // 9


        print(string[0..<1])
        let secondIndex = string.index(after: string.startIndex)
        let thirdIndex = string.index(string.startIndex, offsetBy: 2)
        let lastIndex = string.index(before: string.endIndex)

        
        let abc = string.index(of: "lo", options: String.CompareOptions.backwards)
        let allInd = string.indices(of: "lo")
        allInd.forEach { ind in
            print(ind.distance(in: string))
        }
        let lastIndex1 = string.index(before: string.endIndex)
        print(lastIndex1)
        print(string[lastIndex1])
    }

    func testDict() throws {
        let dict = ConcurrentDict<String, String>()
        dict["1"] = "cde"
        dict["2"] = "abc"
        let val = dict.first { key, value in
            value == "cde1"
        }
        print(dict["2"])
        print(dict["1"])
        XCTAssert(dict["2"] == "abc", "Not equal")

    }

    func testChar() throws {
        let char123: Character = 0
        let char: Character = "\0"
        let char2: Character = "\u{003A}"
        print("as")
        print(char123)
        print(char123 == char)
        print("as0")
        print(char)
        print("as2")
        print(char2)
        print("as3")
    }
}
