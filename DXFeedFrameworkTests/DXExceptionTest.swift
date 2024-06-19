//
//  DXExceptionTest.swift
//  DXFeedFrameworkTests
//
//  Created by Aleksey Kosylo on 01.12.23.
//

import XCTest
@testable import DXFeedFramework

final class DXExceptionTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testException() {
        var failed = false
        do {
            try Isolate.shared.throwException()
        } catch {
            failed = true
        }
        XCTAssert(failed)
    }

}
