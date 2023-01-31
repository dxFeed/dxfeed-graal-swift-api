//
//  DXFeedFrameworkTests.swift
//  DXFeedFrameworkTests
//
//  Created by Aleksey Kosylo on 1/29/23.
//

import XCTest
@testable import DXFeedFramework

class DXFeedFrameworkTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testWrite() throws {
        let a = DXFSystem(DXFEnvironment())
        XCTAssert(a.write("a", forKey: "b"), "Couldn't write value")
    }
    
    func testRead() throws {
        let a = DXFSystem(DXFEnvironment())
        let key = UUID().uuidString
        let value = UUID().uuidString
        XCTAssert(a.write(value, forKey: key), "Couldn't write value")
        XCTAssert(value == a.read(key), "Couldn't read value")
    }
    

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
