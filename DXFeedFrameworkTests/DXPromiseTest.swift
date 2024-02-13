//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import XCTest
@testable import DXFeedFramework

final class DXPromiseTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    private func eventPromise(type: IEventType.Type, symbol: String, feed: DXFeed) throws -> Promise {
        guard let promise =  try feed.getLastEventPromise(type: type, symbol: symbol) else {
            fatalError("Couldnt receive promise")
        }
        return promise
    }

    func testGetResult() {
        do {
            let endpoint = try DXEndpoint.create().connect("demo.dxfeed.com:7300")
            let feed = endpoint.getFeed()
            let promise = try eventPromise(type: Trade.self,
                                           symbol: "ETH/USD:GDAX",
                                           feed: feed!)
            XCTAssert(promise.hasResult() == false)
            let result = try promise.await(millis: 1000)
            XCTAssert(result != nil)
            XCTAssert(result === (try? promise.getResult()))
        } catch {
            XCTAssert(false, "testGetResult \(error)")
        }
    }

    func testGetAyncResult() {
        do {
            let endpoint = try DXEndpoint.create().connect("demo.dxfeed.com:7300")
            let feed = endpoint.getFeed()
            let promise = try eventPromise(type: Trade.self,
                                           symbol: "ETH/USD:GDAX",
                                           feed: feed!)
            XCTAssert(promise.hasResult() == false)
            let receivedEventExp = expectation(description: "Received promise")
            promise.whenDone { [weak promise]_ in
                if (try? promise?.getResult()) != nil {
                    receivedEventExp.fulfill()
                }
            }
            wait(for: [receivedEventExp], timeout: 1)

        } catch {
            XCTAssert(false, "testGetResult \(error)")
        }
    }

    func testGetResultWithException() {
        do {
            let endpoint = try DXEndpoint.create().connect("demo.dxfeed.com:7300")
            let feed = endpoint.getFeed()
            let promise = try eventPromise(type: Trade.self,
                                           symbol: "ETH/USD:GDAX_TEST",
                                           feed: feed!)
            XCTAssert(promise.hasResult() == false)
            _ = try promise.await(millis: 1000)
            XCTAssert(false, "Throws excpetion")
        } catch GraalException.fail(let message, _, _) {
            XCTAssert(message == "await timed out")
        } catch {
            XCTAssert(false, "testGetResultWithException \(error)")
        }
    }

    func testGetIndexedEventResult() {
        do {
            let endpoint = try DXEndpoint.create().connect("demo.dxfeed.com:7300")
            let feed = endpoint.getFeed()
            guard let promise = try feed?.getIndexedEventsPromise(type: Trade.self,
                                                                  symbol: "ETH/USD:GDAX",
                                                                  source: OrderSource.agregateAsk!) else {
                XCTAssert(false, "Promises is nil")
                return
            }
            XCTAssert(!promise.hasResult())
        } catch {
            XCTAssert(false, "testGetIndexedEventResult \(error)")
        }
    }

    func testGetIndexedEventResultWithException() {
        do {
            let endpoint = try DXEndpoint.create().connect("demo.dxfeed.com:7300")
            let feed = endpoint.getFeed()
            guard let promise = try feed?.getIndexedEventsPromise(type: Trade.self,
                                                                  symbol: "ETH/USD:GDAX_TEST",
                                                                  source: OrderSource.agregateAsk!) else {
                XCTAssert(false, "Promises is nil")
                return
            }
            XCTAssert(!promise.hasResult())
            _ = try promise.await(millis: 100)
        } catch GraalException.fail(_, _, _) {
        } catch {
            XCTAssert(false, "testGetIndexedEventResultWithException \(error)")
        }
    }

    func testGetMultipleResults() {
        do {
            let endpoint = try DXEndpoint.create().connect("demo.dxfeed.com:7300")
            let feed = endpoint.getFeed()
            let promises = try feed?.getLastEventPromises(type: Quote.self, symbols: ["ETH/USD:GDAX", "AAPL"])
            if promises?.isEmpty != false {
                XCTAssert(false, "Promises is empty")
            }
            try promises?.forEach({ promise in
                guard let result = try promise.await(millis: 1500), result === (try? promise.getResult()) else {
                    XCTAssert(false, "Result shoud have value")
                    return
                }
            })
        } catch {
            XCTAssert(false, "testGetIndexedEventResult \(error)")
        }
    }

    func testGetAyncMultipleResults() {
        do {
            let symbols = ["ETH/USD:GDAX", "AAPL"]
            let endpoint = try DXEndpoint.create().connect("demo.dxfeed.com:7300")
            let feed = endpoint.getFeed()
            let promises = try feed?.getLastEventPromises(type: Quote.self, symbols: symbols)
            if promises?.isEmpty != false {
                XCTAssert(false, "Promises is empty")
            }
            let expectations = Dictionary(uniqueKeysWithValues:
                                            symbols.map { ($0, expectation(description: "Received promise \($0)")) })
            promises?.forEach({
                $0.whenDone { promise in
                    if let result = try? promise.getResult() {
                        let expectation = expectations[result.eventSymbol]
                        expectation?.fulfill()
                    }
                }
            })
            wait(for: Array(expectations.values), timeout: 1)
        } catch {
            XCTAssert(false, "testGetIndexedEventResult \(error)")
        }
    }

    func testGetMultipleResultsWithException() {
        do {
            let endpoint = try DXEndpoint.create().connect("demo.dxfeed.com:7300")
            let feed = endpoint.getFeed()
            let promises = try feed?.getLastEventPromises(type: Quote.self, symbols: ["ETH/USD:GDAX_TEST", "AAPL_TEST"])
            if promises?.isEmpty != false {
                XCTAssert(false, "Promises is empty")
            }
            try promises?.forEach({ promise in
                guard let result = try promise.await(millis: 1000), result === (try? promise.getResult()) else {
                    XCTAssert(false, "Result shoud have value")
                    return
                }
            })
        } catch GraalException.fail(let message, _, _) {
            XCTAssert(message == "await timed out")
        } catch {
            XCTAssert(false, "testGetMultipleResultsWithException \(error)")
        }
    }

    func testGetTimeSeriesResult() {
        do {
            let endpoint = try DXEndpoint.create().connect("demo.dxfeed.com:7300")
            let feed = endpoint.getFeed()
            guard let promise = try feed?.getTimeSeriesPromise(type: Candle.self,
                                                               symbol: "ETH/USD:GDAX",
                                                               fromTime: 1000,
                                                               toTime: 0) else {
                XCTAssert(false, "Promises is nil")
                return
            }
            _ = try promise.getResults()
        } catch {
            XCTAssert(false, "testGetTimeSeriesResult \(error)")
        }
    }

    func testAllOffPromises() {
        do {
            let endpoint = try DXEndpoint.create().connect("demo.dxfeed.com:7300")
            let feed = endpoint.getFeed()
            let promise = try eventPromise(type: Profile.self, symbol: "IBM", feed: feed!)
            guard var promises = try feed?.getLastEventPromises(type: Quote.self,
                                                                symbols: ["ETH/USD:GDAX", "AAPL"]) else {
                XCTAssert(false, "Empty promises")
                return
            }
            promises.append(promise)
            let finalPromise = try Promise.allOf(promises: promises)
            let receivedEventExp = expectation(description: "Received promise")
            receivedEventExp.expectedFulfillmentCount = promises.count
            finalPromise?.whenDone(handler: { _ in
                promises.forEach { promise in
                    if (try? promise.getResult()) != nil {
                        receivedEventExp.fulfill()
                    }
                }
            })
            wait(for: [receivedEventExp], timeout: 1)
            promises.removeAll()
            wait(seconds: 1)
        } catch {
            XCTAssert(false, "testAllOffPromises \(error)")
        }

    }

}
