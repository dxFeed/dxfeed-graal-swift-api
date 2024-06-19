//
//  EndpointTest.swift
//  DXFeedFrameworkTests
//
//  Created by Aleksey Kosylo on 21.03.2023.
//

import XCTest
@testable import DXFeedFramework

final class EndpointTest: XCTestCase {
    static let port = 7301
    let endpointAddress = "localhost:\(EndpointTest.port)"
    static var publisherEndpoint: DXEndpoint?

    override class func setUp() {
        publisherEndpoint = try? DXEndpoint.builder().withRole(.publisher).withProperty("test", "value").build()
        try? publisherEndpoint?.connect(":\(EndpointTest.port)")
    }

    override class func tearDown() {
        try? publisherEndpoint?.close()
    }

    override func setUpWithError() throws {}

    override func tearDownWithError() throws {}

    func testBuilder() throws {
        let endpoint = try DXEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        XCTAssertNotNil(endpoint, "Endpoint shouldn't be nil")
    }
    func testDealloc() throws {
        var endpoint: DXEndpoint? = try DXEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        print(endpoint ?? "default endpoint value")
        endpoint = nil
        wait(seconds: 3)
    }
    func testFeed() throws {
        let endpoint: DXEndpoint? = try DXEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        XCTAssertNotNil(endpoint, "Endpoint should be not nil")
        let feed = endpoint?.getFeed()
        XCTAssertNotNil(feed, "Feed should be not nil")
    }
    func testConnect() throws {

        let endpoint: DXEndpoint? = try DXEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        XCTAssertNotNil(endpoint, "Endpoint should be not nil")

        let expectations = [DXEndpointState.connected: expectation(description: "Connected"),
                            DXEndpointState.connecting: expectation(description: "Connecting"),
                            DXEndpointState.notConnected: expectation(description: "NotConnected")]
        let listener = TestListener(expectations: expectations)
        endpoint?.add(listener)
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
        var endpoint: DXEndpoint? = try DXEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
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
        let builder = DXEndpoint.builder()
        func isSupportedProperty(_ prop: String, _ expected: Bool) {
            XCTAssert(try builder.isSupported(property: prop) == expected, "Graal doesn't support property \(prop)")
        }
        DXEndpoint.Property.allCases.forEach { prop in
            isSupportedProperty(prop.rawValue, true)
        }
        isSupportedProperty("wrong property", false)
    }

    func testReconnect() throws {
        let endpoint = try DXEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        XCTAssertNotNil(endpoint, "Endpoint should be not nil")
        try endpoint.connect(endpointAddress)
        wait(seconds: 1)
        try endpoint.reconnect()
        wait(seconds: 1)
        try endpoint.close()
    }

    func testDisconnectAndClear() throws {
        let endpoint = try DXEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        XCTAssertNotNil(endpoint, "Endpoint should be not nil")
        try endpoint.connect(endpointAddress)
        wait(seconds: 1)
        try endpoint.disconnectAndClear()
        wait(seconds: 1)
    }

    fileprivate func testGetInstance(role: Role, count: Int) {
        var endpoints = [DXEndpoint]()
        var expectations = [XCTestExpectation]()
        let appendQueue = DispatchQueue(label: "thread-safe-obj", attributes: .concurrent)
        let maxEndpoints = count
        for value in 1...maxEndpoints {
            let name = "test_queue_\(value)"
            let testQueue = DispatchQueue(label: name, attributes: .concurrent)
            let exp = expectation(description: name)
            expectations.append(exp)
            testQueue.async {
                if let endpoint = try? DXEndpoint.getInstance(role) {
                    appendQueue.async(flags: .barrier) {
                        endpoints.append(endpoint)
                        exp.fulfill()
                    }
                }
            }
        }
        wait(for: expectations, timeout: 2)
        XCTAssert(endpoints.count == maxEndpoints,
                  "Number of endpoints \(endpoints.count) should be equal \(maxEndpoints)")
        let filtered = endpoints.filter { endpoint in
            endpoint !== endpoints.first
        }
        XCTAssert(filtered.count == 0, "All values aren't unique")
    }

    func testGetInstance() throws {
        let endpoint1 = try DXEndpoint.getInstance(.feed)
        let endpoint2 = try DXEndpoint.getInstance(.feed)
        XCTAssert(endpoint1 === endpoint2, "Endpoints should be equal")
        testGetInstance(role: .feed, count: 150)
        testGetInstance(role: .publisher, count: 150)
    }
}
