//
//  FeedTests.swift
//  DXFFrameworkTests
//
//  Created by Aleksey Kosylo on 2/4/23.
//

import XCTest
@testable import DXFFramework

final class FeedTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFetchFeed() throws {        
        let address = "demo.dxfeed.com:7300"
        let env = DXFEnvironment()
        let connection = DXFConnection(env, address: address)
        let connected = connection.connect()
        XCTAssert(connected, "Couldn't connect to demo \(address)")
        let predicate = NSPredicate(format: "%K == \(Connected.rawValue)", #keyPath(DXFConnection.state))
        let publishExpectation = XCTNSPredicateExpectation(predicate: predicate, object: connection)
        wait(for: [publishExpectation], timeout: 10)
        let feed = DXFFeed(connection, env: env)
        let subscription = DXFSubscription(env, feed: feed, type: .quote)
        let listener = TestListener()
        let listener1 = TestListener()
        
        subscription.add(listener)
        subscription.add(listener1)
    
        subscription.subscribe("ETH/USD:GDAX")
        let expectation = keyValueObservingExpectation(for: listener, keyPath: "count") { (value, value1) in
            return listener.count >= 30
        }
        let expectation1 = keyValueObservingExpectation(for: listener1, keyPath: "count") { (value, value1) in
            return listener.count >= 50
        }
        
        wait(for: [expectation, expectation1], timeout: 210)

        

//        let predicateFeed = NSPredicate(format: "%K.count > 30", #keyPath(TestListener.items))
//
//
//        let publishFeedExpectation = XCTNSPredicateExpectation(predicate: predicateFeed, object: listener)
//
//        wait(for: [publishFeedExpectation], timeout: 30)
    }

}