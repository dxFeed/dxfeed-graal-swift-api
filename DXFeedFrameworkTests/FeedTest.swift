//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import XCTest
@testable import DXFeedFramework

final class FeedTest: XCTestCase {
    func testInitializationWithNilNativeSubscription() {
        XCTAssertThrowsError(try DXFeedSubscription(native: nil, types: [Quote.self])) { error in
            // Assert
            XCTAssertTrue(error is ArgumentException)
        }
    }

    func testFeedCreation() throws {
        let endpoint: DXEndpoint? = try DXEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        XCTAssertNotNil(endpoint, "Endpoint shouldn't be nil")
        var feed = endpoint?.getFeed()
        XCTAssertNotNil(feed, "Feed shouldn't be nil")
        feed = nil
    }

    func testFeedCreateMultipleSubscription() throws {
        let endpoint: DXEndpoint? = try DXEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        XCTAssertNotNil(endpoint, "Endpoint shouldn't be nil")
        let feed = endpoint?.getFeed()
        XCTAssertNotNil(feed, "Feed shouldn't be nil")
        var subscription = try feed?.createSubscription([Order.self,
                                                         TimeAndSale.self,
                                                         AnalyticOrder.self,
                                                         Summary.self])
        XCTAssertNotNil(subscription, "Subscription shouldn't be nil")
        subscription = nil
    }

    func testFeedCreateSingleSubscription() throws {
        let endpoint: DXEndpoint? = try DXEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        XCTAssertNotNil(endpoint, "Endpoint shouldn't be nil")
        let feed = endpoint?.getFeed()
        XCTAssertNotNil(feed, "Feed shouldn't be nil")
        var subscription = try feed?.createSubscription(Order.self)
        XCTAssertNotNil(subscription, "Subscription shouldn't be nil")
        subscription = nil
    }

    func testCreateSymbol() throws {
        // "as Any" to avoid compile time warnings
        XCTAssertNotNil(("AAPL" as Any) as? Symbol, "String is not a symbol")
        print("asd".description)
        XCTAssertNotNil((WildcardSymbol.all as Any) as? Symbol, "String is not a symbol")
        print(WildcardSymbol.all.stringValue)
        let symbol = try CandleSymbol.valueOf("test")
        XCTAssertNotNil((TimeSeriesSubscriptionSymbol(symbol: symbol,
                                                      fromTime: 0) as Any) as? Symbol, "String is not a symbol")

        let symbol1 = try CandleSymbol.valueOf("test")
        let testString = TimeSeriesSubscriptionSymbol(symbol: symbol1, fromTime: 10).stringValue
        print(testString)
    }

    func testCreateSubscriptionWithSymbol() throws {
        try createMultipleSubscriptionWithSymbol(symbols: ["ETH/USD:GDAX"])
    }

    func testCreateSubscriptionWithSymbols() throws {
        try createMultipleSubscriptionWithSymbol(symbols: ["ETH/USD:GDAX", "XBT/USD:GDAX"])
    }

    func createMultipleSubscriptionWithSymbol(symbols: [String]) throws {
        let endpoint: DXEndpoint? = try DXEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        try endpoint?.connect("demo.dxfeed.com:7300")
        XCTAssertNotNil(endpoint, "Endpoint shouldn't be nil")
        let feed = endpoint?.getFeed()
        XCTAssertNotNil(feed, "Feed shouldn't be nil")
        var differentSymbols = Set<String>()
        let type = Quote.self
        let subscription = try feed?.createSubscription(type)
        let receivedEventExp = expectation(description: "Received events \(type)")
        receivedEventExp.assertForOverFulfill = false
        let listener = AnonymousClass { anonymCl in
            anonymCl.callback = { events in
                events.forEach { event in
                    differentSymbols.insert(event.quote.eventSymbol)
                }
                if Array(differentSymbols) == symbols {
                    receivedEventExp.fulfill()
                }
            }
            return anonymCl
        }
        try subscription?.add(listener: listener)
        XCTAssertNotNil(subscription, "Subscription shouldn't be nil")
        if symbols.count == 1 {
            try subscription?.addSymbols(symbols.first!)
        } else {
            try subscription?.addSymbols(symbols)
        }
        wait(for: [receivedEventExp], timeout: 5)

        try subscription?.removeSymbols(symbols)
    }

    func testTimeAndSale() throws {
        try waitingEvent(TimeAndSale.self)
    }

    func testQuote() throws {
        try waitingEvent(Quote.self)
    }

    func testTrade() throws {
        try waitingEvent(Trade.self)
    }

    func testProfile() throws {
        try waitingEvent(Profile.self)
    }

    func testSeries() throws {
        try waitingEvent(Series.self)
    }

    func testOrder() throws {
        try waitingEvent(Order.self)
    }

//    func testOptionSale() throws {
//        try waitingEvent(code: .optionSale)
//    }

    static func checkType(_ code: EventCode, _ event: MarketEvent?) -> Bool {
        switch code {
        case .timeAndSale:
            return event is TimeAndSale
        case .quote:
            return event is Quote
        case .profile:
            return event is Profile
        case .summary:
            break
        case .greeks:
            break
        case .candle:
            return event is Candle
        case .dailyCandle:
            break
        case .underlying:
            break
        case .theoPrice:
            break
        case .trade:
            return event is Trade
        case .tradeETH:
            break
        case .configuration:
            break
        case .message:
            break
        case .orderBase:
            break
        case .order:
            return event is Order
        case .analyticOrder:
            return event is AnalyticOrder
        case .spreadOrder:
            return event is SpreadOrder
        case .series:
            return event is Series
        case .optionSale:
            return event is OptionSale
        }
        return false
    }

    func waitingEvent(_ type: IEventType.Type) throws {
        let endpoint = try DXEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        try endpoint.connect("demo.dxfeed.com:7300")
        let subscription = try endpoint.getFeed()?.createSubscription(type)
        let receivedEventExp = expectation(description: "Received events \(type)")
        receivedEventExp.assertForOverFulfill = false
        let listener = AnonymousClass { anonymCl in
            anonymCl.callback = { events in
                if events.count > 0 {
                    let event = events.first
                    if FeedTest.checkType(type.type, event) {
                        receivedEventExp.fulfill()
                    }
                }
            }
            return anonymCl
        }
        try subscription?.add(listener: listener)
        try subscription?.addSymbols(["ETH/USD:GDAX", "IBM"])
        wait(for: [receivedEventExp], timeout: 10)
    }
}
