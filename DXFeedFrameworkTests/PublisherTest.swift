//
//  PublisherTest.swift
//  DXFeedFrameworkTests
//
//  Created by Aleksey Kosylo on 13.10.23.
//

import XCTest
@testable import DXFeedFramework

final class PublisherTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCreatePublisher() throws {
        try execute()
    }

    func execute() throws {
        do {
            let endpoint: DXEndpoint? = try DXEndpoint
                .builder()
                .withRole(.publisher)
                .withProperty("test", "value")
                .build()
            try endpoint?.connect(":7400")

            let testQuote = Quote("AAPL")
            testQuote.bidSize = 100
            testQuote.askPrice = 666
            try? testQuote.setSequence(10)
            let feedEndpoint = try DXEndpoint
                .builder()
                .withRole(.feed)
                .withProperty("test", "value")
                .build()
            let publisher = endpoint?.getPublisher()
            let connectedExpectation = expectation(description: "Connected")
            let stateListener: TestEndpoointStateListener? = TestEndpoointStateListener { listener in
                listener.callback = { state in
                    if state == .connected {
                        connectedExpectation.fulfill()
                        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.3) {
                            print(Thread.current.threadName)
                            try? publisher?.publish(events: [testQuote])
                        }
                    }
                }
                return listener
            }

            feedEndpoint.add(listener: stateListener!)
            let subscription = try feedEndpoint.getFeed()?.createSubscription(.quote)
            try feedEndpoint.connect("localhost:7400")
            let receivedEventExp = expectation(description: "Received events \(EventCode.quote)")
            receivedEventExp.assertForOverFulfill = false

            let listener = AnonymousClass { anonymCl in
                anonymCl.callback = { _ in
                    receivedEventExp.fulfill()
                }
                return anonymCl
            }

            try subscription?.add(listener: listener)
            try subscription?.addSymbols(["AAPL"])
            wait(for: [connectedExpectation], timeout: 1)
            wait(for: [receivedEventExp], timeout: 20)
        } catch {
            print("\(error)")
        }
    }
}
