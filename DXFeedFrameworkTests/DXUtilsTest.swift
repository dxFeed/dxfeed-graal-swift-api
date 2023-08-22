//
//  DXUtilsTest.swift
//  DXFeedFrameworkTests
//
//  Created by Aleksey Kosylo on 18.08.23.
//

import XCTest
@testable import DXFeedFramework

final class DXUtilsTest: XCTestCase {

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
