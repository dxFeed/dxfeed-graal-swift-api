//
//  FeedTest.swift
//  DxFeedSwiftFrameworkTests
//
//  Created by Aleksey Kosylo on 26.05.23.
//

import XCTest
@testable import DxFeedSwiftFramework

final class FeedTest: XCTestCase {
    func testFeedCreation() throws {
        var endpoint: DXFEndpoint? = try DXFEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        XCTAssertNotNil(endpoint, "Endpoint shouldn't be nil")
        var feed = endpoint?.getFeed()
        XCTAssertNotNil(feed, "Feed shouldn't be nil")
        feed = nil
    }
}
