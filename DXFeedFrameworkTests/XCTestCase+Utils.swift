//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import XCTest

extension XCTestCase {
    func wait(seconds: Int) {
        _ = XCTWaiter.wait(for: [expectation(description: "\(seconds) seconds waiting")],
                           timeout: TimeInterval(seconds))
    }

    func wait(millis: Float) {
        let seconds = millis / 1000
        _ = XCTWaiter.wait(for: [expectation(description: "\(millis) millis waiting")],
                           timeout: TimeInterval(seconds))
    }
}
