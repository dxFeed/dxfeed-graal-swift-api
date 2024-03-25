//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import XCTest
@testable import DXFeedFramework

final class PublisherTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCreatePublisher() throws {
        try execute()
    }

    func execute() throws {
        do {
            let endpoint: DXEndpoint? = try DXEndpoint
                .builder()
                .withRole(.publisher)
                .withProperty("test", "value")
                .build()
            try endpoint?.connect(":7400")

            let testQuote = Quote("AAPL")
            testQuote.bidSize = 100
            testQuote.askPrice = 666
            try? testQuote.setSequence(10)
            let feedEndpoint = try DXEndpoint
                .builder()
                .withRole(.feed)
                .withProperty("test", "value")
                .build()
            let publisher = endpoint?.getPublisher()
            let connectedExpectation = expectation(description: "Connected")
            let stateListener: TestEndpoointStateListener? = TestEndpoointStateListener { listener in
                listener.callback = { state in
                    if state == .connected {
                        connectedExpectation.fulfill()
                        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.3) {
                            print(Thread.current.threadName)
                            try? publisher?.publish(events: [testQuote])
                        }
                    }
                }
                return listener
            }

            feedEndpoint.add(listener: stateListener!)
            let subscription = try feedEndpoint.getFeed()?.createSubscription(Quote.self)
            try feedEndpoint.connect("localhost:7400")
            let receivedEventExp = expectation(description: "Received events \(EventCode.quote)")
            receivedEventExp.assertForOverFulfill = false

            let listener = AnonymousClass { anonymCl in
                anonymCl.callback = { _ in
                    receivedEventExp.fulfill()
                }
                return anonymCl
            }

            try subscription?.add(listener: listener)
            try subscription?.addSymbols(["AAPL"])
            wait(for: [connectedExpectation], timeout: 1)
            wait(for: [receivedEventExp], timeout: 20)
        } catch {
            print("\(error)")
        }
    }

    func testOtcPublishing() throws {
        throw XCTSkip("skip. otc not ready")

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
        order2.marketMaker = "MM1"
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
        let receivedEvent2Exp = expectation(description: "Received events \(SYMBOL2)")

        let testEventListenr = AnonymousClass { anonymCl in
            anonymCl.callback = { events in
                if events.count > 0 {
                    let event = events.first!.otcMarketsOrder

                    if event.eventSymbol == SYMBOL1 {
                        XCTAssert(event.price == order1.price)
                        XCTAssert(event.quoteAccessPayment == order1.quoteAccessPayment)
                        XCTAssert(event.isOpen == order1.isOpen)
                        XCTAssert(event.isUnsolicited == order1.isUnsolicited)
                        XCTAssert(event.otcMarketsPriceType == order1.otcMarketsPriceType)
                        XCTAssert(event.isSaturated == order1.isSaturated)
                        XCTAssert(event.isAutoExecution == order1.isAutoExecution)
                        XCTAssert(event.isNmsConditional == order1.isNmsConditional)
                        XCTAssert(event.otcMarketsFlags == order1.otcMarketsFlags)
                        receivedEvent1Exp.fulfill()
                    } else if event.eventSymbol == SYMBOL2 {
                        XCTAssert(event.price == order2.price)

                        XCTAssert(event.quoteAccessPayment == order2.quoteAccessPayment)
                        XCTAssert(event.isOpen == order2.isOpen)
                        XCTAssert(event.isUnsolicited == order2.isUnsolicited)
                        XCTAssert(event.otcMarketsPriceType == order2.otcMarketsPriceType)
                        XCTAssert(event.isSaturated == order2.isSaturated)
                        XCTAssert(event.isAutoExecution == order2.isAutoExecution)
                        XCTAssert(event.isNmsConditional == order2.isNmsConditional)
                        XCTAssert(event.otcMarketsFlags == order2.otcMarketsFlags)
                        receivedEvent2Exp.fulfill()
                    }
                    print(event)
                }
            }
            return anonymCl
        }
        try sub.add(listener: testEventListenr)
        let publisher = endpoint.getPublisher()
        try sub.addSymbols([SYMBOL1, SYMBOL2])
        try publisher?.publish(events: [order1, order2])
        wait(for: [receivedEvent1Exp, receivedEvent2Exp], timeout: 1)

    }
}
