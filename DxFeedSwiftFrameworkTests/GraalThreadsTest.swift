//
//  GraalThreadsTest.swift
//  DxFeedSwiftFrameworkTests
//
//  Created by Aleksey Kosylo on 14.03.2023.
//

import XCTest
@testable import DxFeedSwiftFramework

final class GraalThreadsTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEqulity() throws {
        let keeper = GraalThreadManager.shared.attachThread()
        let keeper2 = GraalThreadManager.shared.attachThread()
        XCTAssert(keeper === keeper2)
        XCTAssert(keeper.thread.pointee == keeper2.thread.pointee)
    }
    
    func testThreadInAppleThreads() {
        let keeper = GraalThreadManager.shared.attachThread()
        var th: Thread? = Thread {
            let keeper1 = GraalThreadManager.shared.attachThread()
            XCTAssert(keeper !== keeper1)
        }
        th?.start()
        th = nil
        let sec = 2
        _ = XCTWaiter.wait(for: [expectation(description: "\(sec) seconds waiting")], timeout: TimeInterval(sec))
    }      

}
