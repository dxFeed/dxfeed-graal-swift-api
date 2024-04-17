//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import XCTest
@testable import DXFeedFramework

final class DXAttachTest: XCTestCase {
    let detachedSymbol = "TEST1"
    let attachedSymbol = "TEST2"
    var endpoint: DXEndpoint!
    var feed: DXFeed!
    var publisher: DXPublisher!

    override func setUpWithError() throws {
        endpoint = try DXEndpoint.create()
        feed = endpoint.getFeed()
        publisher = endpoint.getPublisher()
    }

    func testAttachDetach() throws {
        do {
            let subcription = try feed.createSubscription([TimeAndSale.self])
            let expectation1 = expectation(description: "Events received")
            let expectation2 = expectation(description: "Events received")
            let listener = AnonymousClass { anonymCl in
                anonymCl.callback = { events in
                    events.forEach { event in
                        switch event.eventSymbol {
                        case self.detachedSymbol:
                            XCTFail("Received detached symbol \(event.toString())")
                        case self.attachedSymbol:
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

            try publisher.publish(events: [TimeAndSale(attachedSymbol).also(block: { tns in
                tns.askPrice = 100
            })])
            wait(for: [expectation1], timeout: 1)
            try subcription.detach(feed: feed)
            try publisher.publish(events: [TimeAndSale(detachedSymbol)])
            try subcription.attach(feed: feed)
            try publisher.publish(events: [TimeAndSale(attachedSymbol).also(block: { tns in
                tns.askPrice = 200
            })])
            wait(for: [expectation2], timeout: 1)
            let symbols = try subcription.getSymbols().map { symbol in
                symbol.stringValue
            }
            XCTAssert(Set(symbols) == Set([attachedSymbol, detachedSymbol]))
        } catch {
            XCTAssert(false, "Error during attach/detach \(error)")
        }
    }

}
