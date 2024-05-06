//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import XCTest
@testable import DXFeedFramework

final class EndpointTest: XCTestCase {
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

    func testSupportProperty() throws {
        let builder = DXEndpoint.builder()
        func isSupportedProperty(_ prop: String, _ expected: Bool) {
            XCTAssert(try builder.isSupported(prop) == expected, "Graal doesn't support property \(prop)")
        }
        DXEndpoint.Property.allCases.forEach { prop in
            isSupportedProperty(prop.rawValue, true)
        }
        isSupportedProperty("wrong property", false)
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

    func testGetEventTypes() throws {
        let endpoint = try DXEndpoint.create().connect("demo.dxfeed.com:7300")
        defer {
            try? endpoint.closeAndAwaitTermination()
        }
        let connectedExpectation = expectation(description: "Connected")

        let stateListener: TestEndpoointStateListener? = TestEndpoointStateListener { listener in
            listener.callback = { state in
                if state == .connected {
                    print("Connected")
                    do {
                        let types = try endpoint.getEventTypes()
                        print(types)
                    } catch {
                        print(error)
                    }
                    connectedExpectation.fulfill()
                }
            }
            return listener
        }
        endpoint.add(listener: stateListener!)
        wait(for: [connectedExpectation], timeout: 1)
    }

    func testRoleConvert() throws {
        let roles: [DXEndpoint.Role] = [.feed, .onDemandFeed, .streamFeed, .publisher, .streamPublisher, .localHub]
        let nativeCodes = roles.map { role in
            role.toNatie()
        }
        XCTAssertEqual(nativeCodes.map { nativeRole in
            DXEndpoint.Role.fromNative(nativeRole)
        }, roles)
    }

}
