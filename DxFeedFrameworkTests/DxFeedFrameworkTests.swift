//
//  DxFeedFrameworkTests.swift
//  DxFeedFrameworkTests
//
//  Created by Aleksey Kosylo on 1/29/23.
//

import XCTest
@testable import DxFeedFramework

class DxFeedFrameworkTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testWrite() throws {
        let a = DxFSystem(DxFEnvironment())
        XCTAssert(a.write("a", forKey: "b"), "Couldn't write value")
    }
    
    func testRead() throws {
        let a = DxFSystem(DxFEnvironment())
        let key = UUID().uuidString
        let value = UUID().uuidString
        XCTAssert(a.write(value, forKey: key), "Couldn't write value")
        XCTAssert(value == a.read(key), "Couldn't read value")
    }
    
    func testCyrilicRead() throws {
        let a = DxFSystem(DxFEnvironment())
        let key = UUID().uuidString
        let value = "Привет это кирилица" + UUID().uuidString
        XCTAssert(a.write(value, forKey: key), "Couldn't write value")
        let fetchedValue = a.read(key);
        XCTAssert(value == fetchedValue, "Couldn't read value")
    }
    
    func testEmojiRead() throws {
        let a = DxFSystem(DxFEnvironment())
        let key = UUID().uuidString
        let value = "😀Привет это кирилица👨‍👨‍👦" + UUID().uuidString
        XCTAssert(a.write(value, forKey: key), "Couldn't write value")
        let fetchedValue = a.read(key);
        XCTAssert(value == fetchedValue, "Couldn't read value")
    }
    
    func testConnection() throws {
        let address = "demo.dxfeed.com:7300"
        let connection = DxFConnection(DxFEnvironment(), address: address)
        let connected = connection.connect()
        XCTAssert(connected, "Couldn't connect to demo \(address)")
        let predicate = NSPredicate(format: "%K == \(Connected.rawValue)", #keyPath(DxFConnection.state))
        let publishExpectation = XCTNSPredicateExpectation(predicate: predicate, object: connection)
        wait(for: [publishExpectation], timeout: 10)
    }
    

    func testConnectionToWrongAddress() throws {
        let address = "demo1.dxfeed.com:7300"
        let connection = DxFConnection(DxFEnvironment(), address: address)
        let connected = connection.connect()
        XCTAssert(connected, "Couldn't connect to demo \(address)")
        let predicate = NSPredicate(format: "%K == \(Connecting.rawValue)", #keyPath(DxFConnection.state))
        let publishExpectation = XCTNSPredicateExpectation(predicate: predicate, object: connection)
        wait(for: [publishExpectation], timeout: 20)
        
    }
    
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
