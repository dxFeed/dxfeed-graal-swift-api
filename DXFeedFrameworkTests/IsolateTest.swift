//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import XCTest
@testable import DXFeedFramework

final class IsolateTest: XCTestCase {
    func testCleanup() throws {
        // just use it to avoid warnings
        try XCTSkipIf(true, "Just for manual running")
        let isolate = Isolate.shared
        isolate.cleanup()
        let sec = 5
        _ = XCTWaiter.wait(for: [expectation(description: "\(sec) seconds waiting")], timeout: TimeInterval(sec))
    }

}
