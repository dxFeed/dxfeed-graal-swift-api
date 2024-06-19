//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import XCTest
@testable import DXFeedFramework

private class DXConnectionListener: DXEventListener {
    let expectation: XCTestExpectation

    init(expectation: XCTestExpectation) {
        self.expectation = expectation
        self.expectation.assertForOverFulfill = false
    }

    func receiveEvents(_ events: [MarketEvent]) {
        expectation.fulfill()
        events.forEach {
            print($0.toString())
        }
    }
}

extension DXConnectionListener: Hashable {
    static func == (lhs: DXConnectionListener, rhs: DXConnectionListener) -> Bool {
        return lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine("\(self):\(stringReference(self))")
    }

}

final class DXConnectionTest: XCTestCase {
    override class func setUp() {
        // The experimental property must be enabled.
        try? SystemProperty.setProperty("dxfeed.experimental.dxlink.enable", "true")
        // Set scheme for dxLink.
        try? SystemProperty.setProperty("scheme", "ext:resource:dxlink.xml")
    }

    func testDXLinkConnection() throws {
        // For token-based authorization, use the following address format:
        // "dxlink:wss://demo.dxfeed.com/dxlink-ws[login=dxlink:token]"
        let endpoint = try DXEndpoint.builder()
            .build()

        let subscription = try endpoint.getFeed()?.createSubscription(Quote.self)
        let receivedEventsExpectation = expectation(description: "Received events")
        let eventListener = DXConnectionListener(expectation: receivedEventsExpectation)
        try subscription?.add(listener: eventListener)
        try subscription?.addSymbols("AAPL")
        try endpoint.connect("dxlink:wss://demo.dxfeed.com/dxlink-ws")

        wait(for: [receivedEventsExpectation], timeout: 2)
    }

    func testConnection() throws {
        // For token-based authorization, use the following address format:
        // "demo.dxfeed.com:7300[login=entitle:token]"
        let endpoint = try DXEndpoint.builder()
            .build()
        let subscription = try endpoint.getFeed()?.createSubscription(Quote.self)
        let receivedEventsExpectation = expectation(description: "Received events")
        let eventListener = DXConnectionListener(expectation: receivedEventsExpectation)
        try subscription?.add(listener: eventListener)
        try subscription?.addSymbols("AAPL")
        try endpoint.connect("demo.dxfeed.com:7300")

        wait(for: [receivedEventsExpectation], timeout: 2)
    }
}
