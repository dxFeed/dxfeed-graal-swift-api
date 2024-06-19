//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import XCTest
@testable import DXFeedFramework

final class DXTimeSeriesSubscriptionTest: XCTestCase {

    func testCreateSubscriptionForMultipleEvents() throws {
        try createSubscriptionFor(multiple: true)
        try createSubscriptionFor(multiple: false)
    }

    func testCreateWithNil() throws {
        XCTAssertThrowsError(try DXFeedTimeSeriesSubscription(native: nil, types: [Candle.self])) { error in
            XCTAssertTrue(error is ArgumentException)
        }
    }

    func createSubscriptionFor(multiple: Bool) throws {
        let endpoint = try DXEndpoint.create().connect("demo.dxfeed.com:7300")
        let feed = endpoint.getFeed()

        let subscription = multiple ? try feed?.createTimeSeriesSubscription([Candle.self]) :
        try feed?.createTimeSeriesSubscription(Candle.self)
        let receivedEventsExpectation = expectation(description: "Received events")
        receivedEventsExpectation.assertForOverFulfill = false
        let listener = AnonymousClass { anonymCl in
            anonymCl.callback = { _ in
                receivedEventsExpectation.fulfill()
            }
            return anonymCl
        }
        try subscription?.add(listener: listener)
        try subscription?.set(fromTime: 10000)
        try subscription?.addSymbols(["ETH/USD:GDAX", "IBM"])
        wait(for: [receivedEventsExpectation], timeout: 2.0)
        try endpoint.closeAndAwaitTermination()
    }

    func testGeneric() throws {
        let endpoint = try DXEndpoint.create().connect("demo.dxfeed.com:7300")
        let feed = endpoint.getFeed()
        _ = try feed?.createTimeSeriesSubscription(Candle.self)
        _ = try feed?.createTimeSeriesSubscription(TimeAndSale.self)
        _ = try feed?.createTimeSeriesSubscription(Greeks.self)
    }

}
