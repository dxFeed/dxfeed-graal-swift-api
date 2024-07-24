//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import XCTest
@testable import DXFeedFramework

// swiftlint:disable function_body_length
final class PublisherTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCreatePublisher() throws {
        // this test tries reproducing situation when object catched in graal thread
        try execute()
        wait(seconds: 2)
    }

    func execute() throws {
        do {
            let endpoint: DXEndpoint? = try DXEndpoint
                .builder()
                .withRole(.publisher)
                .withProperty("test", "value")
                .build()
            try endpoint?.connect(":7400")

            let order = Order("AAPL")
            order.index = 0

            order.orderSide = .buy
            order.eventSource = OrderSource.ntv!
            order.eventFlags = 0
            order.size = 100
            order.price = 666
            let feedEndpoint = try DXEndpoint
                .builder()
                .withRole(.feed)
                .withProperty("test", "value")
                .build()
            let publisher = endpoint?.getPublisher()
            let connectedExpectation = expectation(description: "Connected")
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.3) {
                print("\(pthread_mach_thread_np(pthread_self()))")
                print(Thread.current.threadName)
            }
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.3) {
                print("\(pthread_mach_thread_np(pthread_self()))")
                print(Thread.current.threadName)
            }
            let stateListener: TestEndpoointStateListener? = TestEndpoointStateListener { listener in
                listener.callback = { state in
                    if state == .connected {
                        connectedExpectation.fulfill()
                        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.3) {
                            print("\(pthread_mach_thread_np(pthread_self()))")
                            print(Thread.current.threadName)
                            try? publisher?.publish(events: [order])
                        }
                    }
                }
                return listener
            }

            feedEndpoint.add(listener: stateListener!)
            let subscription = try feedEndpoint.getFeed()?.createSubscription(Order.self)
            try feedEndpoint.connect("localhost:7400")
            let receivedEventExp = expectation(description: "Received events \(EventCode.quote)")
            receivedEventExp.assertForOverFulfill = false

            let listener = AnonymousClass { anonymCl in
                anonymCl.callback = { events in
                    events.forEach { event in
                        print(event.toString())
                    }
                    receivedEventExp.fulfill()
                }
                return anonymCl
            }

            try subscription?.add(listener: listener)
            let symbol = IndexedEventSubscriptionSymbol(symbol: "AAPL", source: OrderSource.ntv!)

            try subscription?.addSymbols([symbol])
            wait(for: [connectedExpectation], timeout: 1)
            wait(for: [receivedEventExp], timeout: 20)
        } catch {
            print("\(error)")
        }
    }

    func testPublishing() throws {
        do {
            let endpoint: DXEndpoint? = try DXEndpoint
                .builder()
                .withRole(.localHub)
                .build()

            let publisher = endpoint?.getPublisher()

            let subscription = try endpoint?.getFeed()?.createSubscription(Order.self, Trade.self)
            let orderExpectation = expectation(description: "Received events \(EventCode.order)")
            orderExpectation.assertForOverFulfill = false

            let tradeExpectation = expectation(description: "Received events \(EventCode.trade)")

            let listener = AnonymousClass { anonymCl in
                anonymCl.callback = { events in
                    events.forEach { event in
                        print(event.toString())
                    }
                    events.forEach { event in
                        if event.type == .order {
                            orderExpectation.fulfill()
                        } else if event.type == .trade {
                            tradeExpectation.fulfill()
                        }
                    }

                }
                return anonymCl
            }

            try subscription?.add(listener: listener)
            let symbol = IndexedEventSubscriptionSymbol(symbol: "AAPL", source: OrderSource.ntv!)

            try subscription?.addSymbols([symbol])
            let order = Order("AAPL")
            order.index = 0

            order.orderSide = .buy
            order.eventSource = OrderSource.ntv!
            order.eventFlags = 0
            order.size = 100
            order.price = 666
            let trade = Trade("AAPL")
            try? publisher?.publish(events: [order, trade])
            //            wait(for: [connectedExpectation], timeout: 1)
            wait(for: [orderExpectation, tradeExpectation], timeout: 20)
        } catch {
            print("\(error)")
        }
       }

    func testDEtachThread() {
        // create isolate in main thread
        try? SystemProperty.setProperty("test", "test")

        var thread: Thread? = Thread {
            // touch graal in background
            try? SystemProperty.setProperty("test", "test")
        }
        thread?.start()
        thread = nil
        wait(seconds: 2)
    }
}
// swiftlint:enable function_body_length
