//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import XCTest
@testable import DXFeedFramework

final class UtilsTest: XCTestCase {

    func testAsciiCharToString() throws {
        XCTAssert(StringUtil.encodeChar(char: 32) == " ", "Not correct ascii conversation")
        XCTAssert(StringUtil.encodeChar(char: 126) == "~", "Not correct ascii conversation")
    }

    func testUnicodeCharToString() throws {
        XCTAssert(StringUtil.encodeChar(char: 300) == "\\u012C", "Not correct ascii conversation")
    }

    func testCharacter() {
        let char = Character(UnicodeScalar(122)!)
        XCTAssert(char == "z", "Wrong")
    }

}
