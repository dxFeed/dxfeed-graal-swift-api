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
        endpoint = nil
        let sec = 5
        _ = XCTWaiter.wait(for: [expectation(description: "\(sec) seconds waiting")], timeout: TimeInterval(sec))
    }
    func testFeed() throws {
        let endpoint: DXFEndpoint? = try DXFEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        XCTAssertNotNil(endpoint, "Feed should be not nil")
        let feed = endpoint?.getFeed()
        XCTAssertNotNil(feed, "Feed should be not nil")
    }
}
