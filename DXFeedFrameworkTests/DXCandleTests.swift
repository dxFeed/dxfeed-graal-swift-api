//
//  DXCandleTests.swift
//  DXFeedFrameworkTests
//
//  Created by Aleksey Kosylo on 13.07.23.
//

import XCTest
@testable import DXFeedFramework

final class DXCandleTests: XCTestCase {

    func testFetchingCandlesByString() throws {
//        let code = EventCode.candle
//        var endpoint: DXEndpoint? = try DXEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
//        try endpoint?.connect("demo.dxfeed.com:7300")
//        let subscription = try endpoint?.getFeed()?.createSubscription(code)
//        let receivedEventExp = expectation(description: "Received events \(code)")
//        receivedEventExp.assertForOverFulfill = false
//        subscription?.add(AnonymousClass { anonymCl in
//            anonymCl.callback = { events in
//                if events.count > 0 {
//                    events.forEach { event in
//                        print(event)
//                    }
//                    receivedEventExp.fulfill()
//                }
//            }
//            return anonymCl
//        })
//        try subscription?.addSymbols(TimeSeriesSubscriptionSymbol(symbol: "AAPL{=2d}", fromTime: 1660125159))
//        wait(for: [receivedEventExp], timeout: 10)
//        try? endpoint?.disconnect()
//        endpoint = nil
//        let sec = 5
//        _ = XCTWaiter.wait(for: [expectation(description: "\(sec) seconds waiting")], timeout: TimeInterval(sec))
    }

    func testFetchingCandlesBySymbol() throws {
        let code = EventCode.candle
        var endpoint: DXEndpoint? = try DXEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        try endpoint?.connect("demo.dxfeed.com:7300")
        let subscription = try endpoint?.getFeed()?.createSubscription(code)
        let receivedEventExp = expectation(description: "Received events \(code)")
        receivedEventExp.assertForOverFulfill = false
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

        try subscription?.addSymbols(TimeSeriesSubscriptionSymbol(symbol: CandleSymbol.valueOf("AAPL&A{=3d}"), fromTime: 1660125159))
        wait(for: [receivedEventExp], timeout: 10)
        try? endpoint?.disconnect()
        endpoint = nil
        let sec = 5
        _ = XCTWaiter.wait(for: [expectation(description: "\(sec) seconds waiting")], timeout: TimeInterval(sec))
    }

    func testCandleTypeEnum() throws {
        let fvalue = try? CandleType.parse("d")
        let svalue = try? CandleType.parse("Days")
        XCTAssert(fvalue == CandleType.day && svalue == CandleType.day, "Should be day enum")
    }
}
