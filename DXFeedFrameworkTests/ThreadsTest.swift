//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import XCTest
@testable import DXFeedFramework

final class ThreadsTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEquality() throws {
        let keeper = currentThread()
        DispatchQueue.main.async {
            let keeper2 = currentThread()
            XCTAssert(keeper == keeper2)
        }
    }

    func testInDifferentThreads() {
        let keeper = currentThread()
        var thread: Thread? = Thread {
            let keeper1 = currentThread()
            XCTAssert(keeper != keeper1)
        }
        thread?.start()
        thread = nil
        let sec = 2
        _ = XCTWaiter.wait(for: [expectation(description: "\(sec) seconds waiting")], timeout: TimeInterval(sec))
    }

    func testInDifferentQueues() {
        let keeper = currentThread()
        DispatchQueue.global(qos: .background).async {
            let keeper1 = currentThread()
            XCTAssert(keeper != keeper1)
            DispatchQueue.main.async {
                let keeper2 = currentThread()
                XCTAssert(keeper == keeper2)
            }
        }
    }

}
