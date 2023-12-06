//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import XCTest
@testable import DXFeedFramework

final class DXConnectionStateTests: XCTestCase {
    static let port = 7301
    static let endpointAddress = "localhost:\(port)"

    static var publisherEndpoint: DXEndpoint?

    override class func setUp() {
        publisherEndpoint = try? DXEndpoint.builder().withRole(.publisher).withProperty("test", "value").build()
        _ = try? publisherEndpoint?.connect(":\(Self.port)")
    }

    override class func tearDown() {
        try? publisherEndpoint?.close()
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testConnect() throws {
        let endpoint: DXEndpoint? = try DXEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        XCTAssertNotNil(endpoint, "Endpoint should be not nil")

        let expectations = [DXEndpointState.connected: expectation(description: "Connected"),
                            DXEndpointState.connecting: expectation(description: "Connecting"),
                            DXEndpointState.notConnected: expectation(description: "NotConnected")]
        let listener = TestListener(expectations: expectations)
        endpoint?.add(listener: listener)
        let exps = Array(expectations.filter({ element in
            element.key != .notConnected
        }).values)
        try endpoint?.connect(Self.endpointAddress)
        wait(for: exps, timeout: 1)

        try endpoint?.disconnect()
        let expsNotConnected = Array(expectations.filter({ element in
            element.key == .notConnected
        }).values)
        wait(for: expsNotConnected, timeout: 5)
    }

    func testListenerDealloc() throws {
        var endpoint: DXEndpoint? = try DXEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        XCTAssertNotNil(endpoint, "Endpoint should be not nil")
        _ = try endpoint?.connect(Self.endpointAddress)
        var state = try? endpoint?.getState()
        try endpoint?.close()
        try endpoint?.disconnect()
        wait(seconds: 2)
        Isolate.shared.callGC()
        state = try? endpoint?.getState()
        try endpoint?.close()
        state = try? endpoint?.getState()
        Isolate.shared.callGC()
        try endpoint?.close()
        state = try? endpoint?.getState()
        Isolate.shared.callGC()
        state = try? endpoint?.getState()
        endpoint = nil
        endpoint = try DXEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        XCTAssertNotNil(endpoint, "Endpoint should be not nil")
        _ = try endpoint?.connect(Self.endpointAddress)
        try endpoint?.disconnect()
        print("\(state ?? .notConnected)")
        wait(seconds: 3)
    }

    func testReconnect() throws {
        let endpoint = try DXEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        XCTAssertNotNil(endpoint, "Endpoint should be not nil")
        try endpoint.connect(Self.endpointAddress)
        wait(seconds: 1)
        try endpoint.reconnect()
        wait(seconds: 1)
        try endpoint.close()
    }

    func testCreationPublisher() throws {
        var endpoint: DXEndpoint? = try DXEndpoint.builder().withRole(.publisher).build()
        let expectations = [DXEndpointState.connected: expectation(description: "Connected"),
                            DXEndpointState.connecting: expectation(description: "Connecting")]
        let listener = TestListener(expectations: expectations)
        endpoint?.add(listener: listener)
        try endpoint?.connect(":4777")
        let exps = Array(expectations.filter({ element in
            element.key != .notConnected
        }).values)
        wait(for: exps, timeout: 1)
        endpoint = nil
        wait(seconds: 2)
    }

    func testDisconnectAndClear() throws {
        let endpoint = try DXEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        XCTAssertNotNil(endpoint, "Endpoint should be not nil")
        try endpoint.connect(Self.endpointAddress)
        wait(seconds: 1)
        try endpoint.disconnectAndClear()
        wait(seconds: 1)
    }

}
