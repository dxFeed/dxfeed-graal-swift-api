//
//  PublishTest.swift
//  DxFeedFrameworkTests
//
//  Created by Aleksey Kosylo on 19.02.2023.
//

import XCTest
import DxFeedFramework

class TestListenerWithPublish: NSObject, DxFSubscriptionListener {
    var publisher: DxFPublisher? = nil
    func receivedEventsCount(_ count: Int) {
    
    }
    @objc dynamic var count = 0

    var items = [DxFEvent]()
    func receivedEvents(_ events: [DxFEvent]!) {
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
//        let env = DxFEnvironment()
//        let connection = DxFPublisherConnection(env, port: address)
//        let connected = connection.connect()
//        XCTAssert(connected, "Couldn't connect to demo \(address)")
////        let predicate = NSPredicate(format: "%K == \(Connected.rawValue)", #keyPath(DxFConnection.state))
////        let publishExpectation = XCTNSPredicateExpectation(predicate: predicate, object: connection)
////        wait(for: [publishExpectation], timeout: 10)
////        let publisher = DxFPublisher(connection, env: env)
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
        let env = DxFEnvironment()
        let connection = DxFConnection(env, address: address)
        let connected = connection.connect()
        XCTAssert(connected, "Couldn't connect to demo \(address)")
        let predicate = NSPredicate(format: "%K == \(Connected.rawValue)", #keyPath(DxFConnection.state))
        let publishExpectation = XCTNSPredicateExpectation(predicate: predicate, object: connection)
        wait(for: [publishExpectation], timeout: 10)
        let publisher = DxFPublisher(connection, env: env)
        let feed = DxFFeed(connection, env: env)
        let subscription = DxFSubscription(env, feed: feed, type: .timeSale)
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
