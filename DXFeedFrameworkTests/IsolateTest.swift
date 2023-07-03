//
//  IsolateTest.swift
//  DxFeedSwiftFrameworkTests
//
//  Created by Aleksey Kosylo on 14.03.2023.
//

import XCTest
@testable import DXFeedFramework

final class IsolateTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCleanup() throws {
        let isolate = Isolate.shared
        isolate.cleanup()
        let sec = 5
        _ = XCTWaiter.wait(for: [expectation(description: "\(sec) seconds waiting")], timeout: TimeInterval(sec))
    }

}
