//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import XCTest
@testable import DXFeedFramework

final class DXOrderBookModelTest: XCTestCase {

    func testInit() throws {
        let bookModel = try OrderBookModel()
    }

    func testFilters() {
        let allValues = OrderBookModelFilter.allCases
        let allNative = allValues.map { filter in
            filter.toNative()
        }
        XCTAssertEqual(allNative.map { filter in
            OrderBookModelFilter.fromNative(native: filter)
        }, allValues)
    }
}
