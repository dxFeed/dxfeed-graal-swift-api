//
//  OrderTest.swift
//  DXFeedFrameworkTests
//
//  Created by Aleksey Kosylo on 12.10.23.
//

import XCTest
@testable import DXFeedFramework

final class OrderTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testOrder() throws {
        try receiveOrder(code: .order)
    }

    func testAnalyticOrder() throws {
        try receiveOrder(code: .analyticOrder)
    }

    func testSpreadOrder() throws {
        try receiveOrder(code: .spreadOrder)
    }

    private func receiveOrder(code: EventCode) throws {
        let endpoint = try DXEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        try endpoint.connect("demo.dxfeed.com:7300")
        let subscription = try endpoint.getFeed()?.createSubscription(code)
        let receivedEventExp = expectation(description: "Received events \(code)")
        receivedEventExp.assertForOverFulfill = false
        let listener = AnonymousClass { anonymCl in
            anonymCl.callback = { events in
                events.forEach { event in
                    if event.type == .order {
                        print(event.order.toString())
                    }

                }
                if events.count > 0 {
                    let event = events.first
                    if FeedTest.checkType(code, event) {
                        if event?.type == .order {
                            print(event?.order.toString())
                        }
//                        receivedEventExp.fulfill()
                    }
                }
            }
            return anonymCl
        }
        try subscription?.add(observer: listener)
        try subscription?.addSymbols(["IBM"])
        wait(for: [receivedEventExp], timeout: 10)
    }
}
