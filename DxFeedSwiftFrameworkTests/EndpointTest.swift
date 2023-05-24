//
//  EndpointTest.swift
//  DxFeedSwiftFrameworkTests
//
//  Created by Aleksey Kosylo on 21.03.2023.
//

import XCTest
@testable import DxFeedSwiftFramework

final class EndpointTest: XCTestCase {

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
        let sec = 5
        _ = XCTWaiter.wait(for: [expectation(description: "\(sec) seconds waiting")], timeout: TimeInterval(sec))
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
        try endpoint?.connect("demo.dxfeed.com:7300")
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
#warning("TODO: check finalize block")
        var endpoint: DXFEndpoint? = try DXFEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        XCTAssertNotNil(endpoint, "Endpoint should be not nil")
        try endpoint?.connect("demo.dxfeed.com:7300")
        try endpoint?.disconnect()
        endpoint = nil
        let sec = 5
        _ = XCTWaiter.wait(for: [expectation(description: "\(sec) seconds waiting")], timeout: TimeInterval(sec))
    }
}
