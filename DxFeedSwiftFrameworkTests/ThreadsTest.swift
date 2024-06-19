//
//  ThreadsTest.swift
//  DxFeedSwiftFrameworkTests
//
//  Created by Aleksey Kosylo on 14.03.2023.
//

import XCTest
@testable import DxFeedSwiftFramework

final class ThreadsTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEquality() throws {
        let keeper = ThreadManager.shared.attachThread()
        DispatchQueue.main.async {
            let keeper2 = ThreadManager.shared.attachThread()
            XCTAssert(keeper === keeper2)
            XCTAssert(keeper.threadPointer.pointee == keeper2.threadPointer.pointee)
        }
    }

    func testInDifferentThreads() {
        let keeper = ThreadManager.shared.attachThread()
        var thread: Thread? = Thread {
            let keeper1 = ThreadManager.shared.attachThread()
            XCTAssert(keeper !== keeper1)
        }
        thread?.start()
        thread = nil
        let sec = 2
        _ = XCTWaiter.wait(for: [expectation(description: "\(sec) seconds waiting")], timeout: TimeInterval(sec))
    }

    func testInDifferentQueues() {
        let keeper = ThreadManager.shared.attachThread()
        DispatchQueue.global(qos: .background).async {
            let keeper1 = ThreadManager.shared.attachThread()
            XCTAssert(keeper !== keeper1)
            DispatchQueue.main.async {
                let keeper2 = ThreadManager.shared.attachThread()
                XCTAssert(keeper === keeper2)
                XCTAssert(keeper1 !== keeper2)

            }
        }
    }

}
