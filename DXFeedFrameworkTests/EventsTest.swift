//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import XCTest
@testable import DXFeedFramework

final class EventsTest: XCTestCase {
    func testEventEquality() throws {
        let quote = Quote("aa")
        let quote1 = Quote("abc")
        XCTAssert(quote.hashCode != quote1.hashCode)
        XCTAssert(quote.hashCode == quote.hashCode)
    }

    func testConversion() throws {
        let convertedSet = Set(EventCode.allCases.map { $0.nativeCode() }.compactMap { EventCode.convert($0)  })
        let difValues = Array(Set(EventCode.allCases).symmetricDifference(convertedSet))
        XCTAssert(difValues.count == 0, "Not equal enums. Please, take a look on \(difValues)")
    }
}
