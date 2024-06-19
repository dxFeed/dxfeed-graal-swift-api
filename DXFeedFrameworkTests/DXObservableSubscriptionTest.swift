//
//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import XCTest
@testable import DXFeedFramework

final class DXObservableSubscriptionTest: XCTestCase {
    static let profileDescription = "test symbol"
    class PublishListener: ObservableSubscriptionChangeListener {
        weak var publisher: DXPublisher?

        init(publisher: DXPublisher) {
            self.publisher = publisher
        }

        func symbolsAdded(symbols: Set<AnyHashable>) {
            var events = [MarketEvent]()
            symbols.forEach { symbol in
                if let sSymbol = symbol as? Symbol {
                    if sSymbol.stringValue.hasSuffix(":TEST") {
                        let profile = Profile(sSymbol.stringValue)
                        profile.descriptionStr = DXObservableSubscriptionTest.profileDescription
                        events.append(profile)
                    }
                }
            }
            try? publisher?.publish(events: events)

        }

        func symbolsRemoved(symbols: Set<AnyHashable>) {
            // nothing to do here
        }

        func subscriptionClosed() {
            // nothing to do here
        }
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCreateSubscription() throws {
        let events = EventCode.profile
        let port = Int.random(in: 7800..<7900)
        let address = ":\(port)"

        let endpoint = try DXEndpoint.create(.publisher).connect(address)
        let publisher = endpoint.getPublisher()
        let listener = PublishListener(publisher: publisher!)
        let subscription = try publisher?.getSubscription(events)
        try subscription?.addChangeListener(listener)

        let receivedEventsExpectation = expectation(description: "Received events")

        let feedEndpoint = try DXEndpoint.create().connect("localhost:\(port)")
        let feedSubscription = try feedEndpoint.getFeed()?.createSubscription(events)
        let eventListener = AnonymousClass { anonymCl in
            anonymCl.callback = { events in
                events.forEach { mEvent in
                    if mEvent.type == .profile {
                        if mEvent.profile.descriptionStr == DXObservableSubscriptionTest.profileDescription {
                            receivedEventsExpectation.fulfill()
                        }
                    }
                }
            }
            return anonymCl
        }
        try feedSubscription?.add(listener: eventListener)
        try feedSubscription?.addSymbols("AAPL:TEST")
        wait(for: [receivedEventsExpectation], timeout: 2)

        XCTAssert(subscription?.isClosed() == false)
        XCTAssert(feedSubscription?.isClosed() == false)

        XCTAssert(subscription?.eventTypes == Set([events]))
        XCTAssert(feedSubscription?.eventTypes == Set([events]))

        XCTAssert(subscription?.isContains(events) == true)
        XCTAssert(feedSubscription?.isContains(events) == true)

        feedSubscription?.remove(listener: eventListener)
        try subscription?.removeChangeListener(listener)

        try endpoint.closeAndAwaitTermination()
        XCTAssert(subscription?.isClosed() == true)
    }

    func testInitializationWithNilNativeSubscription() {
        XCTAssertThrowsError(try DXObservableSubscription(native: nil, events: [.quote])) { error in
            // Assert
            XCTAssertTrue(error is ArgumentException)
        }
    }

}
