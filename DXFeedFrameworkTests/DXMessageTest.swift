//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import XCTest
@testable import DXFeedFramework

final class DXMessageTest: XCTestCase {
    func testPublishMessage() throws {
        let symbol = StringUtil.random(length: 5)
        let message = TextMessage(symbol)
        let endpoint = try DXEndpoint.create(.localHub)
        let expectation = expectation(description: "Events received")

        let listener = AnonymousClass { anonymCl in
            anonymCl.callback = { events in
                events.forEach { event in
                    print(event.toString())
                    if event.textMessage.eventSymbol == message.eventSymbol {
                        expectation.fulfill()
                    }
                }
            }
            return anonymCl
        }
        let subscription = try endpoint.getFeed()?.createSubscription([TextMessage.self])
        try subscription?.add(listener: listener)
        try subscription?.addSymbols(symbol)

        try endpoint.getPublisher()?.publish(events: [message])
        wait(for: [expectation], timeout: 1.0)
    }

    func testPublishMessageWithText() throws {
        let symbol = StringUtil.random(length: 5)
        let message = TextMessage(symbol)
        message.text = StringUtil.random(length: 25)
        let endpoint = try DXEndpoint.create(.localHub)
        let expectation = expectation(description: "Events received")

        let listener = AnonymousClass { anonymCl in
            anonymCl.callback = { events in
                events.forEach { event in
                    if event.textMessage.eventSymbol == message.eventSymbol &&
                        event.textMessage.text == message.text {
                        expectation.fulfill()
                    }
                }
            }
            return anonymCl
        }
        let subscription = try endpoint.getFeed()?.createSubscription([TextMessage.self])
        try subscription?.add(listener: listener)
        try subscription?.addSymbols(symbol)

        try endpoint.getPublisher()?.publish(events: [message])
        wait(for: [expectation], timeout: 1.0)
    }
}
