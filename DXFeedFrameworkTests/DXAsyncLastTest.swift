//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import XCTest
@testable import DXFeedFramework

final class DXAsyncLocalLastTest: XCTestCase {
    var endpoint: DXEndpoint!
    var feed: DXFeed!
    var publisher: DXPublisher!

    override func setUpWithError() throws {
        endpoint = try DXEndpoint.create(.localHub)
        feed = endpoint.getFeed()
        publisher = endpoint.getPublisher()

    }

    override func tearDownWithError() throws {
        try? endpoint.closeAndAwaitTermination()
    }

    func testLastEventTask() async throws {
        let inputSymbol = StringUtil.random(length: 5)
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.1) {
            try? self.publisher.publish(events: [Trade(inputSymbol)])
        }

        let task = feed.getLastEvent(type: Trade.self,
                                     symbol: inputSymbol)

        let result = await task.result
        switch result {
        case .success(let value):
            XCTAssert(value != nil)
            XCTAssertEqual(value?.eventSymbol, inputSymbol)
        case .failure(let value):
            XCTAssert(false, "\(value)")
        }
    }

    func testLastEventsTask() async throws {
        let inputSymbols = Set([StringUtil.random(length: 5), StringUtil.random(length: 5)])
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.1) {
            try? self.publisher.publish(events: inputSymbols.map({ str in
                let quote = Quote(str)
                quote.askPrice = 100
                return quote
            }))
        }
        let result = await feed.getLastEvents(type: Quote.self, symbols: Array(inputSymbols))
        XCTAssertEqual(result.count, 2)
        let symbols = Set(result.map { event in
            event.eventSymbol
        })
        XCTAssertEqual(symbols, inputSymbols)
    }
}

final class DXAsyncLastTest: XCTestCase {
    var endpoint: DXEndpoint!
    var feed: DXFeed!

    override func setUpWithError() throws {
        endpoint = try DXEndpoint.create().connect("demo.dxfeed.com:7300")
        feed = endpoint.getFeed()
    }

    override func tearDownWithError() throws {
        try? endpoint.closeAndAwaitTermination()
    }

    func testTimeSeriesTask() async throws {
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
        // just use it to avoid warnings
        try XCTSkipIf(true, """
                     Skiped
""")
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
}
