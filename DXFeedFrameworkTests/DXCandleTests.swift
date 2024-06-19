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
//        let code = EventCode.candle
//        let endpoint = try DXEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
//        try endpoint.connect("demo.dxfeed.com:7300")
//        let subscription = try endpoint.getFeed()?.createSubscription(code)
//        let receivedEventExp = expectation(description: "Received events \(code)")
//        subscription?.add(AnonymousClass { anonymCl in
//            anonymCl.callback = { events in
//                if events.count > 0 {
//                    let event = events.first
//                    print(events.count)
//                    if event is Candle {
//                        receivedEventExp.fulfill()
//                    }
//                }
//            }
//            return anonymCl
//        })
//        try subscription?.addSymbols(["AAPL&A{=d,tho=true}"])
//        wait(for: [receivedEventExp], timeout: 10)
    }

}
