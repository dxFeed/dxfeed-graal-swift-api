//
//  DXConnectionTest.swift
//  DXFeedFrameworkTests
//
//  Created by Aleksey Kosylo on 30.11.23.
//

import XCTest
@testable import DXFeedFramework

private class Listener: DXEventListener {
    func receiveEvents(_ events: [MarketEvent]) {
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


//    connect "dxlink:wss://demo.dxfeed.com/dxlink-ws" Quote AAPL -p dxfeed.experimental.dxlink.enable=true
    func testDXLinkConnection() throws {
        try SystemProperty.setProperty("dxfeed.experimental.dxlink.enable", "true")
        let endpoint = try DXEndpoint.builder()
            .withProperty("dxfeed.address", "dxlink:wss://demo.dxfeed.com/dxlink-ws")
            .build()
        let subscription = try endpoint.getFeed()?.createSubscription(EventCode.quote)
        let eventListener = Listener()
        try subscription?.add(listener: eventListener)
        try subscription?.addSymbols("AAPL")
        wait(seconds: 2)
    }

    func testConnection() throws {
        let endpoint = try DXEndpoint.builder()
            .withProperty("dxfeed.address", "demo.dxfeed.com:7300")
            .build()
        let subscription = try endpoint.getFeed()?.createSubscription(EventCode.quote)
        let eventListener = Listener()
        try subscription?.add(listener: eventListener)
        try subscription?.addSymbols("AAPL")
        wait(seconds: 2)
    }





    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
