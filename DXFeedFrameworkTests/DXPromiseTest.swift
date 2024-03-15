//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import XCTest
@testable import DXFeedFramework

// swiftlint:disable type_body_length
final class DXPromiseTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    private func eventPromise(type: IEventType.Type, symbol: String, feed: DXFeed) throws -> Promise {
        guard let promise =  try feed.getLastEventPromise(type: type, symbol: symbol) else {
            XCTAssert(false, "Couldnt receive promise")
            fatalError("Couldnt receive promise")
        }
        return promise
    }

    func testGetAsyncResultWithTimeout() {
        getAsyncResult(timeOut: 1000)
    }

    func testGetAsyncResultWithTimeoutWithoutException() {
        getAsyncResult(timeOut: 1000, withException: false)
    }

    func testGetAsyncResultNoTimeout() {
        getAsyncResult(timeOut: nil)
    }

    func getAsyncResult(timeOut: Int32?, withException: Bool = true) {
        do {
            let endpoint = try DXEndpoint.create().connect("demo.dxfeed.com:7300")
            let feed = endpoint.getFeed()
            let promise = try eventPromise(type: Trade.self,
                                           symbol: "ETH/USD:GDAX",
                                           feed: feed!)
            XCTAssert(promise.hasResult() == false)
            var result: MarketEvent?
            if let timeOut = timeOut {
                if withException {
                    try promise.await(millis: timeOut)
                    result = try promise.getResult()
                } else {
                    if promise.awaitWithoutException(millis: timeOut) {
                        result = try promise.getResult()
                    }
                }
            } else {
                try promise.await()
                result = try promise.getResult()
            }
            XCTAssert(result != nil)
            XCTAssert(promise.hasResult() == true)
            XCTAssert(result === (try? promise.getResult()))
            XCTAssert(promise.isDone() == true)
            XCTAssert(promise.hasException() == false)
        } catch {
            XCTAssert(false, "testGetResult \(error)")
        }
    }

    func testGetAsyncResult() {
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
                XCTAssert(false, "Promise is nil")
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
                XCTAssert(false, "Promise is nil")
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
                try promise.await(millis: 1500)
                guard (try? promise.getResult()) != nil else {
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
                try promise.await(millis: 1000)
                guard (try? promise.getResult()) != nil else {
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
            let date = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
            let endpoint = try DXEndpoint.create().connect("demo.dxfeed.com:7300")
            let feed = endpoint.getFeed()
            guard let promise = try feed?.getTimeSeriesPromise(type: Candle.self,
                                                               symbol: "AAPL{=1d}",
                                                               fromTime: Long(date.millisecondsSince1970),
                                                               toTime: Long.max) else {
                XCTAssert(false, "Empty promise")
                return
            }
            try promise.await(millis: 2000)
            let results = try promise.getResults()
            XCTAssert((results?.count ?? 0) > 0)
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
                XCTAssert(false, "Empty promise")
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

    func testCompletePromise() {
        do {
            let endpoint = try DXEndpoint.create()
            let feed = endpoint.getFeed()
            let promise = try eventPromise(type: Quote.self,
                                           symbol: "ETH/USD:GDAX",
                                           feed: feed!)
            XCTAssert(promise.hasResult() == false)
            let receivedEventExp = expectation(description: "Received promise")
            promise.whenDone { [weak promise]_ in
                if (try? promise?.getResult()) != nil {
                    receivedEventExp.fulfill()
                }
            }
            try promise.complete(result: Quote("AAPL"))
            wait(for: [receivedEventExp], timeout: 1)

        } catch {
            XCTAssert(false, "testCompletePromise \(error)")
        }
    }

    func testCompleteExceptPromise() throws {
        throw XCTSkip("""
                      Graal doesn't have impl for ExceptionMapper.toJava.
                      and always throws exception illegalStateException
""")
        do {
            let endpoint = try DXEndpoint.create()
            let feed = endpoint.getFeed()
            let promise = try eventPromise(type: Quote.self,
                                           symbol: "ETH/USD:GDAX",
                                           feed: feed!)
            XCTAssert(promise.hasResult() == false)
            let receivedEventExp = expectation(description: "Received promise")
            promise.whenDone { _ in
                receivedEventExp.fulfill()
            }
            try promise.completeExceptionally(GraalException.fail(message: "Failed from iOS",
                                                                  className: "TestClas",
                                                                  stack: "Stack empty"))
            wait(for: [receivedEventExp], timeout: 1)
        } catch {
            XCTAssert(false, "testCompleteExceptPromise \(error)")
        }
    }

    func testIsCanceled() throws {
        do {
            let endpoint = try DXEndpoint.create()
            let feed = endpoint.getFeed()
            let promise = try eventPromise(type: Quote.self,
                                           symbol: "ETH/USD:GDAX",
                                           feed: feed!)
            let isCanceled = promise.isCancelled()
            XCTAssert(isCanceled == false)
        } catch {
            XCTAssert(false, "testIsCanceled \(error)")
        }
    }

    func testGetException() throws {
        do {
            let endpoint = try DXEndpoint.create()
            let feed = endpoint.getFeed()
            let promise = try eventPromise(type: Quote.self,
                                           symbol: "ETH/USD:GDAX",
                                           feed: feed!)
            let exception = promise.getException()
            XCTAssert(exception == nil)
        } catch {
            XCTAssert(false, "testGetException \(error)")
        }
    }

    func testCancelPromise() {
        do {
            let endpoint = try DXEndpoint.create()
            let feed = endpoint.getFeed()
            let promise = try eventPromise(type: Quote.self,
                                           symbol: "ETH/USD:GDAX",
                                           feed: feed!)
            XCTAssert(promise.hasResult() == false)
            let receivedEventExp = expectation(description: "Received promise")
            promise.whenDone { [weak promise]_ in
                if promise?.isCancelled() == true {
                    receivedEventExp.fulfill()
                }
            }
            promise.cancel()
            wait(for: [receivedEventExp], timeout: 1)

        } catch {
            XCTAssert(false, "testCompletePromise \(error)")
        }
    }

    func testTimeSeriesTask() async throws {
        let endpoint = try DXEndpoint.create().connect("demo.dxfeed.com:7300")
        let feed = endpoint.getFeed()
        let date = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        guard let task = feed?.getTimeSeries(type: Candle.self,
                                             symbol: "AAPL{=1d}",
                                             fromTime: Long(date.millisecondsSince1970),
                                             toTime: Long.max) else {
            XCTAssert(false, "Async task is nil")
            return
        }
        let result = await task.result
        switch result {
        case .success(let value):
            XCTAssert((value?.count ?? 0) > 0)
        case .failure(let value):
            XCTAssert(false, "\(value)")
        }
    }

    func testIndexedEventTask() async throws {
        throw XCTSkip("""
                     Skiped
""")
        let endpoint = try DXEndpoint.create().connect("demo.dxfeed.com:7300")
        let feed = endpoint.getFeed()
        let date = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        guard let task = feed?.getIndexedEvents(type: Series.self,
                                                symbol: "ETH/USD:GDAX",
                                                source: OrderSource.agregateAsk!) else {
            XCTAssert(false, "Async task is nil")
            return
        }
        let result = await task.result
        switch result {
        case .success(let value):
            XCTAssert((value?.count ?? 0) > 0)
        case .failure(let value):
            XCTAssert(false, "\(value)")
        }
    }

    func testLastEventTask() async throws {
        let endpoint = try DXEndpoint.create().connect("demo.dxfeed.com:7300")
        let feed = endpoint.getFeed()
        let date = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        guard let task = feed?.getLastEvent(type: Trade.self,
                                            symbol: "ETH/USD:GDAX")
        else {
            XCTAssert(false, "Async task is nil")
            return
        }
        let result = await task.result
        switch result {
        case .success(let value):
            XCTAssert(value != nil)
        case .failure(let value):
            XCTAssert(false, "\(value)")
        }
    }

}
// swiftlint:enable type_body_length
