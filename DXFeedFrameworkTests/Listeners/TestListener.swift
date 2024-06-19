//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import XCTest
@testable import DXFeedFramework

class TestListener: DXEndpointListener {
    var expectations: [DXEndpointState: XCTestExpectation]
    init(expectations: [DXEndpointState: XCTestExpectation]) {
        self.expectations = expectations

    }

    func endpointDidChangeState(old: DXEndpointState,
                                new: DXEndpointState) {
        if let expectation = expectations[new] {
            expectation.fulfill()
        }
    }
}

extension TestListener: Hashable {
    static func == (lhs: TestListener, rhs: TestListener) -> Bool {
        return lhs.expectations == rhs.expectations
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(expectations)
    }
}
