//
//  EndpointTest.swift
//  DxFeedSwiftFrameworkTests
//
//  Created by Aleksey Kosylo on 21.03.2023.
//

import XCTest
@testable import DxFeedSwiftFramework

final class EndpointTest: XCTestCase {
    let endpointAddress = "demo.dxfeed.com:7300"
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBuilder() throws {
        let endpoint = try DXFEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        XCTAssertNotNil(endpoint, "Endpoint shouldn't be nil")
    }
    func testDealloc() throws {
        var endpoint: DXFEndpoint? = try DXFEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        print(endpoint ?? "default endpoint value")
        endpoint = nil
        wait(seconds: 5)
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

        class Listener: EndpointListener {
            var state = EndpointState.notConnected
            var expectations: [EndpointState: XCTestExpectation]
            init(expectations: [EndpointState: XCTestExpectation]) {
                self.expectations = expectations
            }
            func changeState(old: DxFeedSwiftFramework.EndpointState, new: DxFeedSwiftFramework.EndpointState) {
                if let expectation = expectations[new] {
                    expectation.fulfill()
                }
            }
        }
        let expectations = [EndpointState.connected: expectation(description: "Connected"),
                            EndpointState.connecting: expectation(description: "Connecting"),
                            EndpointState.notConnected: expectation(description: "NotConnected")]
        let listener = Listener(expectations: expectations)
        endpoint?.appendListener(listener)
        try endpoint?.connect(endpointAddress)
        let exps = Array(expectations.filter({ element in
            element.key != .notConnected
        }).values)
        wait(for: exps, timeout: 5)
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
        wait(seconds: 5)
        try? endpoint?.callGC()
        try endpoint?.close()
        try? endpoint?.callGC()
        endpoint = nil
        wait(seconds: 5)
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
        wait(seconds: 3)
        _ = XCTWaiter.wait(for: [expectation(description: "\(5) seconds waiting")], timeout: TimeInterval(5))
        try endpoint.reconnect()
        wait(seconds: 3)
    }
}
