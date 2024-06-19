//
//  SystemPropertyTest.swift
//  DXFeedFrameworkTests
//
//  Created by Aleksey Kosylo on 17.03.2023.
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

    func testException() {
        do {
            try SystemProperty.test()
        } catch {
            print("Just test exception: \(error)")
        }
    }

    func testSupportedProperties() {

    }
}
