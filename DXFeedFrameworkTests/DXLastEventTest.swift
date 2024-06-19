//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import XCTest
@testable import DXFeedFramework

final class DXLastEventTest: XCTestCase {
    private func testEvents(_ symbol: String) -> [MarketEvent] {
        var result = [MarketEvent]()

        let testQuote = Quote(symbol)
        testQuote.bidSize = Double.random(in: 1000.0..<2000.0)
        testQuote.askPrice = Double.random(in: 1000.0..<2000.0)
        result.append(testQuote)

        let testTrade = Trade(symbol)
        testTrade.price = Double.random(in: 1000.0..<2000.0)
        result.append(testTrade)

        let testTradeEth = TradeETH(symbol)
        testTradeEth.price = Double.random(in: 1000.0..<2000.0)
        result.append(testTradeEth)

        let testProfile = Profile(symbol)
        testProfile.highLimitPrice = Double.random(in: 1000.0..<2000.0)
        result.append(testProfile)

        let summary = Summary(symbol)
        summary.dayId = 10
        result.append(summary)

        if let candleSymbol = try? CandleSymbol.valueOf(symbol) {
            let candle = Candle(candleSymbol)
            result.append(candle)
        }

        let greeks = Greeks(symbol)
        greeks.price = Double.random(in: 1000.0..<2000.0)
        result.append(greeks)

        let underlying = Underlying(symbol)
        underlying.volatility = Double.random(in: 1000.0..<2000.0)
        result.append(underlying)

        let theoPrice = TheoPrice(symbol)
        theoPrice.delta = Double.random(in: 1000.0..<2000.0)
        result.append(theoPrice)

        return result
    }

    private func checkEvent(_ event: ILastingEvent, in events: [MarketEvent]) {
        func getEvent(type: EventCode) -> MarketEvent {
            events.first { mEvent in
                mEvent.type == type
            }!
        }

        switch event {
        case let last as Quote:
            let test = getEvent(type: last.type).quote
            XCTAssert((last.askPrice ~== test.askPrice) &&
                      (last.bidSize ~== test.bidSize))
        case let last as Trade:
            let test = getEvent(type: last.type).trade
            XCTAssert(test.price ~== last.price)
        case let last as TradeETH:
            let test = getEvent(type: last.type).tradeETH
            XCTAssert(test.price ~== last.price)
        case let last as Profile:
            let test = getEvent(type: last.type).profile
            XCTAssert(last.highLimitPrice ~== test.highLimitPrice)
        case let last as Candle:
            let test = getEvent(type: last.type).candle
            XCTAssert(last.eventSymbol == test.eventSymbol)
            XCTAssert(last.close.isNaN)
            XCTAssert(last.askVolume.isNaN)

        case let last as Summary:
            let test = getEvent(type: last.type).summary
            XCTAssert(last.dayId == test.dayId)
        case let last as Greeks:
            let test = getEvent(type: last.type).greeks
            XCTAssert(last.price ~== test.price)
        case let last as Underlying:
            let test = getEvent(type: last.type).underlying
            XCTAssert(last.volatility ~== test.volatility)
        case let last as TheoPrice:
            let test = getEvent(type: last.type).theoPrice
            XCTAssert(last.delta ~== test.delta)
        default:
            XCTAssert(false, "Unhandled last event \(event)")
        }
    }

    func testGetLastEvents() {
        let symbol = "AAPL_TEST{=d}"

        let events = testEvents(symbol)
        getLastEvents(symbol: symbol, events: events) { feed in
            let result = try? feed?.getLastEvents(types: events)
            result?.forEach({ event in
                checkEvent(event, in: events)
            })

            events.forEach { event in
                if let lastEvent = try? feed?.getLastEvent(type: event) {
                    checkEvent(lastEvent, in: events)
                } else {
                    XCTAssert(false, "LastEvent returns nil")
                }
            }
        }
    }

    func getLastEvents(symbol: String, events: [MarketEvent], fetching: ((DXFeed?) -> Void)) {
        do {
            let endpoint: DXEndpoint? = try DXEndpoint.create(.localHub)
            let publisher = endpoint?.getPublisher()
            let connectedExpectation = expectation(description: "Connected")
            let allTypes = [Candle.self,
                            Trade.self,
                            TradeETH.self,
                            Quote.self,
                            TimeAndSale.self,
                            Profile.self,
                            Summary.self,
                            Greeks.self,
                            Underlying.self,
                            TheoPrice.self,
                            Order.self,
                            AnalyticOrder.self,
                            SpreadOrder.self,
                            Series.self,
                            OptionSale.self]
            let subscription = try endpoint?.getFeed()?.createSubscription(allTypes)
            try subscription?.addSymbols(symbol)
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.3) {
                print(Thread.current.threadName)
                try? publisher?.publish(events: events)
                connectedExpectation.fulfill()
            }
            wait(for: [connectedExpectation], timeout: 1)
            fetching(endpoint?.getFeed())
            try endpoint?.closeAndAwaitTermination()
        } catch {
            XCTAssert(false, "\(error)")
        }
    }

}
