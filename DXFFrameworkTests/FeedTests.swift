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
        let feedLoaded = feed.load()
        XCTAssert(feedLoaded, "Couldn't load feed from demo \(address)")
        let predicateFeed = NSPredicate(format: "%K == nil", #keyPath(DXFFeed.values))
        let publishFeedExpectation = XCTNSPredicateExpectation(predicate: predicateFeed, object: feed)
        feed.getForSymbol("ETH/USD:GDAX")
        wait(for: [publishFeedExpectation], timeout: 20)
    }

}
