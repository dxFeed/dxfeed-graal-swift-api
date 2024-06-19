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

}
