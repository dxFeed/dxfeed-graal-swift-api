//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import XCTest
@testable import DXFeedFramework

final class DXOtcMarketOrderTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    // swiftlint:disable function_body_length
    func testOtcPublishing() throws {
        let SYMBOL1 = "AAPL_TEST1"
        let SYMBOL2 = "AAPL_TEST2"
        let order1 = OtcMarketsOrder(SYMBOL1)
        order1.orderSide = .buy
        order1.marketMaker = "MM1"
        order1.scope = .order
        order1.price = 10.0
        order1.size = 1
        order1.index = 1
        order1.quoteAccessPayment = -30
        order1.isOpen = true
        order1.isUnsolicited = true
        order1.otcMarketsPriceType = .actual
        order1.isSaturated = true
        order1.isAutoExecution = true
        order1.isNmsConditional = true

        let order2 = OtcMarketsOrder(SYMBOL2)
        order2.orderSide = .buy
        order2.marketMaker = "MM2"
        order2.scope = .order
        order2.price = 10.0
        order2.size = 1
        order2.index = 1
        order2.quoteAccessPayment = -30
        order2.isOpen = true
        order2.isUnsolicited = true
        order2.otcMarketsPriceType = .wanted
        order2.isSaturated = true
        order2.isAutoExecution = false
        order2.isNmsConditional = false

        let endpoint = try DXEndpoint.create(.localHub)
        let feed = endpoint.getFeed()
        let sub = try feed!.createSubscription([OtcMarketsOrder.self])
        let receivedEvent1Exp = expectation(description: "Received events \(SYMBOL1)")
        receivedEvent1Exp.expectedFulfillmentCount = 2

        let testEventListenr = AnonymousClass { anonymCl in
            anonymCl.callback = { events in
                if events.count > 0 {
                    events.forEach { event in
                        XCTAssertEqual(event.type, .otcMarketsOrder)
                        let event = event.otcMarketsOrder
                        if event.eventSymbol == SYMBOL1 {
                            XCTAssertEqual(event.marketMaker, "MM1")
                            XCTAssertEqual(event.price, 10)
                            XCTAssertEqual(event.quoteAccessPayment, -30)
                            XCTAssertEqual(event.isOpen, true)
                            XCTAssertEqual(event.isUnsolicited, true)
                            XCTAssertEqual(event.otcMarketsPriceType, .actual)
                            XCTAssertEqual(event.isSaturated, true)
                            XCTAssertEqual(event.isAutoExecution, true)
                            XCTAssertEqual(event.isNmsConditional, true)
                            XCTAssertEqual(event.otcMarketsFlags, order1.otcMarketsFlags)
                            receivedEvent1Exp.fulfill()
                        } else if event.eventSymbol == SYMBOL2 {
                            XCTAssertEqual(event.marketMaker, "MM2")
                            XCTAssertEqual(event.price, 10)
                            XCTAssertEqual(event.quoteAccessPayment, -30)
                            XCTAssertEqual(event.isOpen, true)
                            XCTAssertEqual(event.isUnsolicited, true)
                            XCTAssertEqual(event.otcMarketsPriceType, .wanted)
                            XCTAssertEqual(event.isSaturated, true)
                            XCTAssertEqual(event.isAutoExecution, false)
                            XCTAssertEqual(event.isNmsConditional, false)
                            XCTAssertEqual(event.otcMarketsFlags, order2.otcMarketsFlags)
                            receivedEvent1Exp.fulfill()
                        }
                    }
                }
            }
            return anonymCl
        }
        try sub.add(listener: testEventListenr)
        let publisher = endpoint.getPublisher()
        try sub.addSymbols([SYMBOL1, SYMBOL2])
        try publisher?.publish(events: [order1, order2])
        wait(for: [receivedEvent1Exp], timeout: 1)
    }
    // swiftlint:enable function_body_length

}
