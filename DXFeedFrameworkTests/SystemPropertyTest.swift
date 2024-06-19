//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import XCTest
@testable import DXFeedFramework

final class SystemPropertyTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testWrite() throws {
        do {
            try SystemProperty.setProperty("a", "val1")
        } catch {
            XCTAssert(false, "Couldn't write value")
        }

    }

    func testRead() throws {
        let key = UUID().uuidString
        let value = UUID().uuidString
        do {
            try SystemProperty.setProperty(key, value)
        } catch {
            XCTAssert(false, "Couldn't write value")
        }
        XCTAssert(value == SystemProperty.getProperty(key), "Couldn't read value")
    }

    func testCyrilicRead() throws {
        let key = UUID().uuidString
        let value = "Привет это кирилица" + UUID().uuidString
        do {
            try SystemProperty.setProperty(key, value)
        } catch {
            XCTAssert(false, "Couldn't write value")
        }
        XCTAssert(value == SystemProperty.getProperty(key), "Couldn't read value")
    }

    func testEmojiRead() throws {
        let key = UUID().uuidString
        let value = "😀Привет это кирилица👨‍👨‍👦" + UUID().uuidString
        do {
            try SystemProperty.setProperty(key, value)
        } catch {
            XCTAssert(false, "Couldn't write value")
        }
        XCTAssert(value == SystemProperty.getProperty(key), "Couldn't read value")
    }
}
