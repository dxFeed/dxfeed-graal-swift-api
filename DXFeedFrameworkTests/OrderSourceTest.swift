//
//  OrderSourceTest.swift
//  DXFeedFrameworkTests
//
//  Created by Aleksey Kosylo on 10.10.23.
//

import XCTest
@testable import DXFeedFramework

final class OrderSourceTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testIsSpecialSource() throws {
        XCTAssert(OrderSource.isSpecialSourceId(sourceId: 1))
        XCTAssert(!OrderSource.isSpecialSourceId(sourceId: 10))
        XCTAssert(OrderSource.isSpecialSourceId(sourceId: 2))
    }

    func testCompose() throws {
        let res = try OrderSource.composeId(name: "1234")
        XCTAssert(res == 825373492)
    }

    func testCheckChar() throws {
        do {
            try OrderSource.check(char: "a")
        } catch {
            XCTAssert(false, "\(error)")
        }
    }

    func testDecode() throws {
        do {
            let res = try OrderSource.decodeName(identifier: 1)
            print(res)
        } catch {
            print("\(error)")
        }
    }

    func testCreateOrderSourceWithDuplicateName() throws {
        do {
            _ = try OrderSource(identifier: 44, name: "COMPOSITE_ASK", pubFlags: 0)
            _ = try OrderSource(identifier: 33, name: "COMPOSITE_ASK", pubFlags: 0)
        } catch ArgumentException.exception(let message) {
            XCTAssert(message.contains("name"), "Wrong message \(message)")
            return
        } catch {
            print("undefined error \(error)")
        }
        XCTAssert(false, "should be generated exception")
    }

    func testCreateOrderSourceWithDuplicateId() throws {
        do {
            _ = try OrderSource(identifier: 3, name: "COMPOSITE_ASK1", pubFlags: 0)
            _ = try OrderSource(identifier: 3, name: "COMPOSITE_ASK3", pubFlags: 0)
        } catch ArgumentException.exception(let message) {
            XCTAssert(message.contains("id"), "Wrong message \(message)")
            return
        } catch {
            print("undefined error \(error)")
        }
        XCTAssert(false, "should be generated exception")
    }

    func testCreateOrderSource() throws {
        do {
            _ = try OrderSource(identifier: 5, name: "COMPOSITE_ASK2", pubFlags: 0)
            _ = try OrderSource(identifier: 6, name: "COMPOSITE_ASK4", pubFlags: 0)
        } catch {
            XCTAssert(false, "undefined error \(error)")
        }
    }
}
