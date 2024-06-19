//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import XCTest
@testable import DXFeedFramework

final class DXLastEventsSubscribedTest: XCTestCase {
    var endpoint: DXEndpoint?
    var feed: DXFeed?
    var publisher: DXPublisher?

    override func setUpWithError() throws {
        endpoint = try DXEndpoint.create(.localHub)
        feed = endpoint?.getFeed()
        publisher = endpoint?.getPublisher()
    }

    override func tearDownWithError() throws {
        try endpoint?.closeAndAwaitTermination()
    }

    func testGetLastEventIfSubscribed() throws {
        let testSymbol = StringUtil.random(length: 5)

        let quote = try feed?.getLastEventIfSubscribed(type: Quote.self, symbol: testSymbol)
        XCTAssertNil(quote)
        let subscription = try feed?.createSubscription([Quote.self])
        try subscription?.addSymbols(testSymbol)
        try publisher?.publish(events: [Quote(testSymbol).also(block: { quote in
            quote.askPrice = 101
        })])
        let existingQuotes = try feed?.getLastEventIfSubscribed(type: Quote.self, symbol: testSymbol)
        XCTAssertNotNil(existingQuotes)
        XCTAssertEqual(101, (existingQuotes as? Quote)?.askPrice)
    }

    func testGetIndexedEventsIfSubscribed() throws {
        let testSymbol = StringUtil.random(length: 5)
        let type = Order.self
        let nillOrderList = try feed?.getIndexedEventsIfSubscribed(type: type,
                                                                   symbol: testSymbol,
                                                                   source: .defaultSource)
        XCTAssertNotNil(nillOrderList)
        // should be nill
//        XCTAssertNil(nillOrderList)
        let subscription = try feed?.createSubscription([type])
        try subscription?.addSymbols(testSymbol)
        let emptyOrderList = try feed?.getIndexedEventsIfSubscribed(type: type,
                                                                    symbol: testSymbol,
                                                                    source: .defaultSource)
        XCTAssertNotNil(emptyOrderList)

        try publisher?.publish(events: [Order(testSymbol).also(block: { order in
            try? order.setIndex(1)
            order.orderSide = .buy
            order.price = 10.5
            order.size = 100
        })])
        let orderList = try feed?.getIndexedEventsIfSubscribed(type: type, symbol: testSymbol, source: .defaultSource)
        XCTAssertEqual(1, orderList?.count)
        let order = orderList?.first as? Order
        XCTAssertNotNil(order)
        XCTAssertEqual(1, order?.index)
        XCTAssertEqual(Side.buy, order?.orderSide)
        XCTAssertEqual(10.5, order?.price)
        XCTAssertEqual(100, order?.size)
    }

    func testGetTimeSeriesIfSubscribed() throws {
        let candleSymbol = CandleSymbol.valueOf( StringUtil.random(length: 5), [CandlePeriod.day])
        guard let fromTime: Long = try DXTimeFormat.defaultTimeFormat?.parse("20150101"),
              let toTime: Long = try DXTimeFormat.defaultTimeFormat?.parse("20150710") else {
            XCTAssert(false, "Parsing failed")
            return
        }
        let type = Candle.self

        do {
            let nillList = try feed?.getTimeSeriesIfSubscribed(type: type,
                                                               symbol: candleSymbol,
                                                               fromTime: fromTime,
                                                               toTime: toTime)
            XCTAssertNotNil(nillList)
            // should be nill
//            XCTAssertNil(nillList)
        }
        let subscription = try feed?.createSubscription([type])
        do {
            // wrong sub time
            try subscription?.addSymbols(TimeSeriesSubscriptionSymbol(symbol: candleSymbol, fromTime: toTime))
            let nillList = try feed?.getTimeSeriesIfSubscribed(type: type,
                                                               symbol: candleSymbol,
                                                               fromTime: fromTime,
                                                               toTime: toTime)
            XCTAssertNotNil(nillList)
            // should be nill
//            XCTAssertNil(nillList)
        }
        do {
            // right sub time
            try subscription?.addSymbols(TimeSeriesSubscriptionSymbol(symbol: candleSymbol, fromTime: fromTime))
            let nillList = try feed?.getTimeSeriesIfSubscribed(type: type,
                                                               symbol: candleSymbol,
                                                               fromTime: fromTime,
                                                               toTime: toTime)
            XCTAssertNotNil(nillList)
        }
        do {
            // publish something
            try publisher?.publish(events: [Candle(candleSymbol).also(block: { candle in
                candle.time = fromTime
                candle.close = 10.5
                candle.volume = 100
            })])
            let list = try feed?.getTimeSeriesIfSubscribed(type: type,
                                                           symbol: candleSymbol,
                                                           fromTime: fromTime,
                                                           toTime: toTime)
            XCTAssertEqual(1, list?.count)
            let candle = list?.first as? Candle
            XCTAssertNotNil(candle)
            XCTAssertEqual(fromTime, candle?.time)
            XCTAssertEqual(10.5, candle?.close)
            XCTAssertEqual(100, candle?.volume)
        }
    }

}
