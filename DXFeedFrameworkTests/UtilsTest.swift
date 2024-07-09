//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import XCTest
@testable import DXFeedFramework

final class UtilsTest: XCTestCase {

    func testAsciiCharToString() throws {
        XCTAssertEqual(StringUtil.encodeChar(char: 32), " ")
        XCTAssertEqual(StringUtil.encodeChar(char: 126), "~")

        XCTAssertEqual(StringUtil.decodeChar(" "), 32)
        XCTAssertEqual(StringUtil.decodeChar("~"), 126)
    }

    func testUnicodeCharToString() throws {
        XCTAssertEqual(StringUtil.encodeChar(char: 300), "\\u012C")
        XCTAssertEqual(StringUtil.decodeChar("\\u012C"), 300)
    }

    func testCharacter() {
        let char = Character(UnicodeScalar(122)!)
        XCTAssertEqual(char, "z")
    }

}
