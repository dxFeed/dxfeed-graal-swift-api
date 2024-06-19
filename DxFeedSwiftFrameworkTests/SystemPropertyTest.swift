//
//  SystemPropertyTest.swift
//  DxFeedSwiftFrameworkTests
//
//  Created by Aleksey Kosylo on 17.03.2023.
//

import XCTest
@testable import DxFeedSwiftFramework

final class SystemPropertyTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testWrite() throws {
        let status = try SystemProperty.setProperty("a", "val1")
        XCTAssert(status, "Couldn't write value")
    }
    
    func testRead() throws {
        let key = UUID().uuidString
        let value = UUID().uuidString
        let status = try SystemProperty.setProperty(key, value)
        XCTAssert(status == true, "Couldn't write value")
        XCTAssert(value == SystemProperty.getProperty(key), "Couldn't read value")
    }

    func testCyrilicRead() throws {
        let key = UUID().uuidString
        let value = "Привет это кирилица" + UUID().uuidString
        let status = try SystemProperty.setProperty(key, value)
        XCTAssert(status == true, "Couldn't write value")
        XCTAssert(value == SystemProperty.getProperty(key), "Couldn't read value")
    }

    func testEmojiRead() throws {
        let key = UUID().uuidString
        let value = "😀Привет это кирилица👨‍👨‍👦" + UUID().uuidString
        let status = try SystemProperty.setProperty(key, value)
        XCTAssert(status == true, "Couldn't write value")
        XCTAssert(value == SystemProperty.getProperty(key), "Couldn't read value")
    }
    func testException() {
        do {
            try SystemProperty.test()
        } catch {
            print("User creation failed with error: \(error)")
        }
    }
}
