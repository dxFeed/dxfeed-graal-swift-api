//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import XCTest
@testable import DXFeedFramework

final class FeedTest: XCTestCase {

    override class func setUp() {
        _ = Isolate.shared
    }

    func testInitializationWithNilNativeSubscription() {
        XCTAssertThrowsError(try DXFeedSubscription(native: nil, types: [Quote.self])) { error in
            // Assert
            XCTAssertTrue(error is ArgumentException)
        }
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
    }

    func testSetGetSymbols() throws {
        let symbols: [Symbol] = [
            "AAPL_TEST",
            "AAPL_TEST{=d}",
            WildcardSymbol.all,
            CandleSymbol.valueOf("AAPL0", [CandlePeriod.day]),
            TimeSeriesSubscriptionSymbol(symbol: "AAPL2", fromTime: 1),
            IndexedEventSubscriptionSymbol(symbol: "AAPL1", source: .defaultSource),
            IndexedEventSubscriptionSymbol(symbol: "AAPL3", source: OrderSource.ntv!),
            IndexedEventSubscriptionSymbol(symbol: "AAPL4", source: try OrderSource.valueOf(identifier: 1))
        ]
        let endpoint = try DXEndpoint.create()
        let feed = try endpoint.getFeed()?.createSubscription([Candle.self])
        try feed?.setSymbols(symbols)
        if let resultSymbols = try feed?.getSymbols() {
            // Using sets for comparing.
            let inputSymbols = symbols.reduce(into: Set<String>(), { (values, object) in
                values.insert(object.stringValue)
            })
            XCTAssert(inputSymbols.count == symbols.count)
            let equals = inputSymbols == resultSymbols.reduce(into: Set<String>(), { (values, object) in
                values.insert(object.stringValue)
            })
            XCTAssert(equals)
        } else {
            XCTAssert(false, "Subscription returned null")
        }
    }
    

    func testAttachDetach() throws {
        let detachedSymbol = "TEST1"
        let attachedSymbol = "TEST2"
        let endpoint = try DXEndpoint.create()
        do {
            if let feed = endpoint.getFeed(), let publisher = endpoint.getPublisher() {
                let subcription = try feed.createSubscription([TimeAndSale.self])
                let expectation1 = expectation(description: "Events received")
                let expectation2 = expectation(description: "Events received")
                let listener = AnonymousClass { anonymCl in
                    anonymCl.callback = { events in
                        print(events)
                        events.forEach { event in
                            switch event.eventSymbol {
                            case detachedSymbol:
                                XCTFail("Received detached symbol \(event.toString())")
                            case attachedSymbol:
                                if event.timeAndSale.askPrice == 100 {
                                    expectation1.fulfill()
                                } else if event.timeAndSale.askPrice == 200 {
                                    expectation2.fulfill()
                                }
                            default:
                                XCTFail("Unexpected symbol \(event.toString())")
                            }
                        }
                    }
                    return anonymCl
                }
                try subcription.add(listener: listener)
                try subcription.addSymbols(detachedSymbol)
                try feed.detach(subscription: subcription)
                try publisher.publish(events: [TimeAndSale(detachedSymbol)])
                try feed.attach(subscription: subcription)
                try feed.attach(subscription: subcription)
                try subcription.addSymbols(attachedSymbol)

                let tns1 = TimeAndSale(attachedSymbol)
                tns1.askPrice = 100
                try publisher.publish(events: [tns1])
                wait(for: [expectation1], timeout: 1)

                try subcription.detach(feed: feed)
                try publisher.publish(events: [TimeAndSale(detachedSymbol)])
                try subcription.attach(feed: feed)
                tns1.askPrice = 200
                try publisher.publish(events: [tns1])
                wait(for: [expectation2], timeout: 1)
                let symbols = try subcription.getSymbols().map { symbol in
                    symbol.stringValue
                }
                XCTAssert(Set(symbols) == Set([attachedSymbol, detachedSymbol]))
            } else {
                XCTAssert(false, "Subscription returned null")
            }
        } catch {
            XCTAssert(false, "Error during attach/detach \(error)")
        }
    }
}
