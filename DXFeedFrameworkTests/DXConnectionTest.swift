//
//  DXConnectionTest.swift
//  DXFeedFrameworkTests
//
//  Created by Aleksey Kosylo on 30.11.23.
//

import XCTest
@testable import DXFeedFramework

private class Listener: DXEventListener {
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

extension Listener: Hashable {
    static func == (lhs: Listener, rhs: Listener) -> Bool {
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
    }

    func testDXLinkConnection() throws {
        // For token-based authorization, use the following address format:
        // "dxlink:wss://demo.dxfeed.com/dxlink-ws[login=dxlink:token]"
        let endpoint = try DXEndpoint.builder()
            .withProperty("dxfeed.address", "dxlink:wss://demo.dxfeed.com/dxlink-ws")
            .build()
        let subscription = try endpoint.getFeed()?.createSubscription(EventCode.quote)
        let receivedEventsExpectation = expectation(description: "Received events")
        let eventListener = Listener(expectation: receivedEventsExpectation)
        try subscription?.add(listener: eventListener)
        try subscription?.addSymbols("AAPL")
        wait(for: [receivedEventsExpectation], timeout: 2)
    }

    func testConnection() throws {
        // For token-based authorization, use the following address format:
        // "demo.dxfeed.com:7300[login=entitle:token]"
        let endpoint = try DXEndpoint.builder()
            .withProperty("dxfeed.address", "demo.dxfeed.com:7300")
            .build()
        let subscription = try endpoint.getFeed()?.createSubscription(EventCode.quote)
        let receivedEventsExpectation = expectation(description: "Received events")
        let eventListener = Listener(expectation: receivedEventsExpectation)
        try subscription?.add(listener: eventListener)
        try subscription?.addSymbols("AAPL")
        wait(for: [receivedEventsExpectation], timeout: 2)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
