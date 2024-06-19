//
//  EndpointTest.swift
//  DxFeedSwiftFrameworkTests
//
//  Created by Aleksey Kosylo on 21.03.2023.
//

import XCTest
@testable import DxFeedSwiftFramework

final class EndpointTest: XCTestCase {
    static let port = 7301
    let endpointAddress = "localhost:\(EndpointTest.port)"
    static var publisherEndpoint: DXFEndpoint?

    override class func setUp() {
        publisherEndpoint = try? DXFEndpoint.builder().withRole(.publisher).withProperty("test", "value").build()
        try? publisherEndpoint?.connect(":\(EndpointTest.port)")
    }

    override class func tearDown() {
        try? publisherEndpoint?.close()
    }

    override func setUpWithError() throws {}

    override func tearDownWithError() throws {}

    func testBuilder() throws {
        let endpoint = try DXFEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        XCTAssertNotNil(endpoint, "Endpoint shouldn't be nil")
    }
    func testDealloc() throws {
        var endpoint: DXFEndpoint? = try DXFEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        print(endpoint ?? "default endpoint value")
        endpoint = nil
        wait(seconds: 3)
    }
    func testFeed() throws {
        let endpoint: DXFEndpoint? = try DXFEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        XCTAssertNotNil(endpoint, "Endpoint should be not nil")
        let feed = endpoint?.getFeed()
        XCTAssertNotNil(feed, "Feed should be not nil")
    }
    func testConnect() throws {

        let endpoint: DXFEndpoint? = try DXFEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        XCTAssertNotNil(endpoint, "Endpoint should be not nil")

        let expectations = [EndpointState.connected: expectation(description: "Connected"),
                            EndpointState.connecting: expectation(description: "Connecting"),
                            EndpointState.notConnected: expectation(description: "NotConnected")]
        let listener = TestListener(expectations: expectations)
        endpoint?.appendListener(listener)
        try endpoint?.connect(endpointAddress)
        let exps = Array(expectations.filter({ element in
            element.key != .notConnected
        }).values)
        wait(for: exps, timeout: 1)
        try endpoint?.disconnect()
        let expsNotConnected = Array(expectations.filter({ element in
            element.key == .notConnected
        }).values)
        wait(for: expsNotConnected, timeout: 5)
    }

    func testListenerDealloc() throws {
        var endpoint: DXFEndpoint? = try DXFEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        XCTAssertNotNil(endpoint, "Endpoint should be not nil")
        try endpoint?.connect(endpointAddress)
        try endpoint?.disconnect()
        wait(seconds: 2)
        try? endpoint?.callGC()
        try endpoint?.close()
        try? endpoint?.callGC()
        endpoint = nil
        wait(seconds: 3)
    }

    func testSupportProperty() throws {
        let builder = DXFEndpoint.builder()
        func isSupportedProperty(_ prop: String, _ expected: Bool) {
            XCTAssert(try builder.isSupported(property: prop) == expected, "Graal doesn't support property \(prop)")
        }
        DXFEndpoint.Property.allCases.forEach { prop in
            isSupportedProperty(prop.rawValue, true)
        }
        isSupportedProperty("wrong property", false)
    }

    func testReconnect() throws {
        let endpoint = try DXFEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        XCTAssertNotNil(endpoint, "Endpoint should be not nil")
        try endpoint.connect(endpointAddress)
        wait(seconds: 1)
        try endpoint.reconnect()
        wait(seconds: 1)
        try endpoint.close()
    }

    func testDisconnectAndClear() throws {
        let endpoint = try DXFEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        XCTAssertNotNil(endpoint, "Endpoint should be not nil")
        try endpoint.connect(endpointAddress)
        wait(seconds: 1)
        try endpoint.disconnectAndClear()
        wait(seconds: 1)
    }
}
