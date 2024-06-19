//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import XCTest
@testable import DXFeedFramework

final class DXTimeSeriesSubscriptionTest: XCTestCase {

    func testCreateSubscriptionForEvent() throws {
        try createSubscriptionFor(multiple: false)
    }

    func testCreateSubscriptionForMultipleEvents() throws {
        try createSubscriptionFor(multiple: true)
    }

    func testCreateSubscriptionWithUnsupportedEvents() throws {
        let endpoint = try DXEndpoint.create().connect("demo.dxfeed.com:7300")
        let feed = endpoint.getFeed()
        try EventCode.allCases.forEach { eventCode in
            if !eventCode.isTimeSeriesEvent() {
                XCTAssertThrowsError(try feed?.createTimeSeriesSubscription(eventCode)) { error in
                    guard case ArgumentException.invalidOperationException(_) = error else {
                        return XCTFail("Unsupported exception \(error)")
                    }
                }
            }
        }
    }

    func testCreateWithNil() throws {
        XCTAssertThrowsError(try DXFeedTimeSeriesSubscription(native: nil, events: [.candle])) { error in
            XCTAssertTrue(error is ArgumentException)
        }
    }

    func createSubscriptionFor(multiple: Bool) throws {
        let endpoint = try DXEndpoint.create().connect("demo.dxfeed.com:7300")
        let feed = endpoint.getFeed()

        let subscription = multiple ? try feed?.createTimeSeriesSubscription([.candle]) :
        try feed?.createTimeSeriesSubscription(.candle)
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
    }

    
}
