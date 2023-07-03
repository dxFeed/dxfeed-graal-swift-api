//
//  FeedTest.swift
//  DxFeedSwiftFrameworkTests
//
//  Created by Aleksey Kosylo on 26.05.23.
//

import XCTest
@testable import DXFeedFramework

final class FeedTest: XCTestCase {
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
        var subscription = try feed?.createSubscription([.order, .timeAndSale, .analyticOrder, .summary])
        XCTAssertNotNil(subscription, "Subscription shouldn't be nil")
        subscription = nil
    }

    func testFeedCreateSingleSubscription() throws {
        let endpoint: DXEndpoint? = try DXEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        XCTAssertNotNil(endpoint, "Endpoint shouldn't be nil")
        let feed = endpoint?.getFeed()
        XCTAssertNotNil(feed, "Feed shouldn't be nil")
        var subscription = try feed?.createSubscription(.order)
        XCTAssertNotNil(subscription, "Subscription shouldn't be nil")
        subscription = nil
    }

    func testCreateSymbol() throws {
        // "as Any" to avoid compile time warnings
        XCTAssertNotNil(("AAPL" as Any) as? Symbol, "String is not a symbol")
        print("asd".description)
        XCTAssertNotNil((WildcardSymbol() as Any) as? Symbol, "String is not a symbol")
        print(WildcardSymbol().stringValue)
        XCTAssertNotNil((TimeSeriesSubscriptionSymbol() as Any) as? Symbol, "String is not a symbol")
        print(TimeSeriesSubscriptionSymbol().stringValue)
    }

//    func testFeedCreateSingleSubscriptionWithSymbol() throws {
//        let endpoint: DXEndpoint? = try DXEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
//        try endpoint?.connect("demo.dxfeed.com:7300")
//        XCTAssertNotNil(endpoint, "Endpoint shouldn't be nil")
//        let feed = endpoint?.getFeed()
//        XCTAssertNotNil(feed, "Feed shouldn't be nil")
//        let subscription = try feed?.createSubscription(.quote)
//        let testListner = TestEventListener(name: "TestListener")
//        subscription?.add(testListner)
//        XCTAssertNotNil(subscription, "Subscription shouldn't be nil")
//        try subscription?.addSymbols("ETH/USD:GDAX")
//        wait(seconds: 2)
//    }

    func testFeedCreateMultipleSubscriptionWithSymbol() throws {
        let endpoint: DXEndpoint? = try DXEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        try endpoint?.connect("demo.dxfeed.com:7300")
        XCTAssertNotNil(endpoint, "Endpoint shouldn't be nil")
        let feed = endpoint?.getFeed()
        XCTAssertNotNil(feed, "Feed shouldn't be nil")
        let subscription = try feed?.createSubscription(.quote)
        let testListner = TestEventListener(name: "TestListener")
        subscription?.add(testListner)
        XCTAssertNotNil(subscription, "Subscription shouldn't be nil")
        try subscription?.addSymbols(["AAPL", "ETH/USD:GDAX", "IBM"])
        wait(seconds: 2)
    }

    func testTimeAndSale() throws {
        try waitingEvent(code: .timeAndSale)
    }

    func testQuote() throws {
        try waitingEvent(code: .quote)
    }

    func testTrade() throws {
        try waitingEvent(code: .trade)
    }

    func testProfile() throws {
        try waitingEvent(code: .profile)
    }

    fileprivate static func checkType(_ code: EventCode, _ event: MarketEvent?) -> Bool {
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
            break
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
            break
        case .analyticOrder:
            break
        case .spreadOrder:
            break
        case .series:
            break
        case .optionSale:
            break
        }
        return false
    }

    func waitingEvent(code: EventCode) throws {

        let endpoint = try DXEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        try endpoint.connect("demo.dxfeed.com:7300")
        let subscription = try endpoint.getFeed()?.createSubscription(code)
        let receivedEventExp = expectation(description: "Received events \(code)")
        subscription?.add(AnonymousClass { anonymCl in
            anonymCl.printFunc = { events in
                if events.count > 0 {
                    let event = events.first
                    if FeedTest.checkType(code, event) {
                        receivedEventExp.fulfill()
                    }
                }
            }
            return anonymCl
        })
        try subscription?.addSymbols(["ETH/USD:GDAX"])
        wait(for: [receivedEventExp], timeout: 5)
    }
}
