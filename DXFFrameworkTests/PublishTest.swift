//
//  PublishTest.swift
//  DXFFrameworkTests
//
//  Created by Aleksey Kosylo on 19.02.2023.
//

import XCTest
import DXFFramework

class TestListenerWithPublish: NSObject, DXFSubscriptionListener {
    var publisher: DXFPublisher? = nil
    func receivedEventsCount(_ count: Int) {
    
    }
    @objc dynamic var count = 0

    var items = [DXFEvent]()
    func receivedEvents(_ events: [DXFEvent]!) {
        print(events ?? "Empty events")
        count += events.count
        items.append(contentsOf: events)
        self.publisher?.publish([Int]())
    }
}


final class PublishTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testFetchFeed() throws {
//        let address = "tape:WriteTapeFile.out.txt[format=text]"
//        let env = DXFEnvironment()
//        let connection = DXFPublisherConnection(env, port: address)
//        let connected = connection.connect()
//        XCTAssert(connected, "Couldn't connect to demo \(address)")
////        let predicate = NSPredicate(format: "%K == \(Connected.rawValue)", #keyPath(DXFConnection.state))
////        let publishExpectation = XCTNSPredicateExpectation(predicate: predicate, object: connection)
////        wait(for: [publishExpectation], timeout: 10)
////        let publisher = DXFPublisher(connection, env: env)
//
//        let listener = TestListener()
//        let expectation = keyValueObservingExpectation(for: listener, keyPath: "count") { (value, value1) in
//            return listener.count >= 30
//        }
//        wait(for: [expectation], timeout: 30)

        

//        let predicateFeed = NSPredicate(format: "%K.count > 30", #keyPath(TestListener.items))
//
//
//        let publishFeedExpectation = XCTNSPredicateExpectation(predicate: predicateFeed, object: listener)
//
//        wait(for: [publishFeedExpectation], timeout: 30)
    }
    func test() throws {
        let address = "localhost:6666"
        let env = DXFEnvironment()
        let connection = DXFConnection(env, address: address)
        let connected = connection.connect()
        XCTAssert(connected, "Couldn't connect to demo \(address)")
        let predicate = NSPredicate(format: "%K == \(Connected.rawValue)", #keyPath(DXFConnection.state))
        let publishExpectation = XCTNSPredicateExpectation(predicate: predicate, object: connection)
        wait(for: [publishExpectation], timeout: 10)
        let publisher = DXFPublisher(connection, env: env)
        let feed = DXFFeed(connection, env: env)
        let subscription = DXFSubscription(env, feed: feed, type: .timeSale)
        let listener = TestListenerWithPublish()
        listener.publisher = publisher
        subscription.add(listener)
    
        subscription.subscribe("TEST1")
        let expectation = keyValueObservingExpectation(for: listener, keyPath: "count") { (value, value1) in
            return listener.count >= 30
        }
        let expectation1 = keyValueObservingExpectation(for: listener, keyPath: "count") { (value, value1) in
            return listener.count >= 50
        }
        publisher.publish([Int]())
        wait(for: [expectation, expectation1], timeout: 210)
    }
}
