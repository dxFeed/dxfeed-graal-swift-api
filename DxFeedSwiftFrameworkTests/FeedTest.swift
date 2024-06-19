//
//  FeedTest.swift
//  DxFeedSwiftFrameworkTests
//
//  Created by Aleksey Kosylo on 26.05.23.
//

import XCTest
@testable import DxFeedSwiftFramework

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

    func testApiLikeGithubSample() throws {
        let endpoint = try DXEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        try endpoint.connect("demo.dxfeed.com:7300")
        let subscription = try endpoint.getFeed()?.createSubscription(.quote)
        subscription?.add(AnonymousClass { ec in
            ec.someFunc = { print("It worked") }
            return ec
        })
    }
}
