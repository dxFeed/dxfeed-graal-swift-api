//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import XCTest
@testable import DXFeedFramework

final class CandleTests: XCTestCase {
    let type = Candle.self

    func testFetchingCandlesByString() throws {
        let symbol = TimeSeriesSubscriptionSymbol(symbol: "AAPL{=15d}", fromTime: 1660125159)
        try fetchCandles(symbol)
    }

    func testFetchingCandlesByString1() throws {
        let symbol = TimeSeriesSubscriptionSymbol(symbol: "AAPL{=10d}", fromTime: 1660125159)
        try fetchCandles(symbol)
    }

    func testFetchingSymbolWithDate() throws {
        let string = "01/01/2023"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        let symbol = TimeSeriesSubscriptionSymbol(symbol: "AAPL{=2d}", date: dateFormatter.date(from: string)!)
        try fetchCandles(symbol)
    }

    func testFetchingCandlesBySymbol() throws {
        let candleSymbol = try CandleSymbol.valueOf("AAPL&A{=3d}")
        let symbol = TimeSeriesSubscriptionSymbol(symbol: candleSymbol, fromTime: 1660125159)
        try fetchCandles(symbol)
    }

    func testFetchingCandlesByLongSymbol() throws {
        let candleSymbol = try CandleSymbol.valueOf("AAPL{=3y,price=bid,tho=true}")
        let symbol = TimeSeriesSubscriptionSymbol(symbol: candleSymbol, fromTime: 1660125159)
        try fetchCandles(symbol)
    }

    func testFetchingCandlesByAttrbuteSymbol() throws {
        let period = CandlePeriod.valueOf(value: 100, type: .day)
        let price = try CandlePrice.parse("mark")
        let session = try CandleSession.parse("true")
        let alignment = try CandleAlignment.parse("s")
        let candleSymbol = CandleSymbol.valueOf("AAPL", [period, alignment, price, session])
        let symbol = TimeSeriesSubscriptionSymbol(symbol: candleSymbol, fromTime: 1660125159)
        try fetchCandles(symbol)
    }

    func fetchCandles(_ symbol: TimeSeriesSubscriptionSymbol) throws {
        var endpoint: DXEndpoint? = try DXEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        try endpoint?.connect("demo.dxfeed.com:7300")
        let subscription = try endpoint?.getFeed()?.createSubscription(type)
        let receivedEventExp = expectation(description: "Received events \(type)")
        receivedEventExp.assertForOverFulfill = false
        let listener = AnonymousClass { anonymCl in
            anonymCl.callback = { events in
                if events.count > 0 {
                    events.forEach { event in
                        print(event)
                    }
                    receivedEventExp.fulfill()
                }
            }
            return anonymCl
        }
        try subscription?.add(listener: listener)
        try subscription?.addSymbols(symbol)
        wait(for: [receivedEventExp], timeout: 10)
        try? endpoint?.disconnect()
        try endpoint?.closeAndAwaitTermination()
        endpoint = nil

    }

    func testParseShortSymbol() throws {
        let symbol = try CandleSymbol.valueOf("AAPL&C{tho=true,=d}")
        checkSymbol(symbol,
                    baseSymbol: "AAPL",
                    period: 1,
                    pType: .day,
                    price: .defaultPrice,
                    session: CandleSession.regular,
                    alignment: .defaultAlignment,
                    priceLevel: CandlePriceLevel.defaultCandlePriceLevel?.value,
                    exchangeCode: "C")
        let symbol2 = try CandleSymbol.valueOf("AAPL{tho=true,=d}")
        checkSymbol(symbol2,
                    baseSymbol: "AAPL",
                    period: 1,
                    pType: .day,
                    price: .defaultPrice,
                    session: CandleSession.regular,
                    alignment: .defaultAlignment,
                    priceLevel: CandlePriceLevel.defaultCandlePriceLevel?.value,
                    exchangeCode: CandleExchange.defaultExchange.exchangeCode)
    }

    func testParseLongSymbol() throws {
        let candleSymbol = try CandleSymbol.valueOf("AAPL{=3y,price=bid,tho=true,a=s,pl=1000.5}")
        XCTAssert(candleSymbol.baseSymbol == "AAPL", "Please check base symbol")
        checkSymbol(candleSymbol,
                    baseSymbol: "AAPL",
                    period: 3,
                    pType: .year,
                    price: CandlePrice.bid,
                    session: CandleSession.regular,
                    alignment: .session,
                    priceLevel: 1000.5,
                    exchangeCode: CandleExchange.defaultExchange.exchangeCode)
    }

    func testCreationSymbol() throws {
        let exchange = CandleExchange.valueOf("A")
        let period = CandlePeriod.valueOf(value: 100, type: .day)
        let priceLevel = try CandlePriceLevel.valueOf(value: 999.35)
        let price = try CandlePrice.parse("mark")
        let session = try CandleSession.parse("true")
        let alignment = try CandleAlignment.parse("s")
        let candleSymbol = CandleSymbol.valueOf("AAPL", [exchange, period, alignment, priceLevel, price, session])
        checkSymbol(candleSymbol,
                    baseSymbol: "AAPL",
                    period: 100.0,
                    pType: .day,
                    price: CandlePrice.mark,
                    session: CandleSession.regular,
                    alignment: .session,
                    priceLevel: 999.35,
                    exchangeCode: "A")
    }
    // swiftlint:disable function_parameter_count
    private func checkSymbol(_ candleSymbol: CandleSymbol,
                             baseSymbol: String,
                             period: Double?,
                             pType: CandleType?,
                             price: CandlePrice?,
                             session: CandleSession?,
                             alignment: CandleAlignment?,
                             priceLevel: Double?,
                             exchangeCode: Character) {
        XCTAssert(candleSymbol.baseSymbol == baseSymbol, "Base symbol is not correct")
        XCTAssert(candleSymbol.period?.value == period, "Period value is not correct")
        XCTAssert(candleSymbol.period?.type == pType, "Period type is not correct")
        XCTAssert(candleSymbol.price == price, "Price is not correct")
        XCTAssert(candleSymbol.session == session, "Session is not correct")
        XCTAssert(candleSymbol.alignment == alignment, "Alignment is not correct")
        if candleSymbol.priceLevel?.value.isNaN != true && priceLevel?.isNaN != true {
            XCTAssert(candleSymbol.priceLevel?.value == priceLevel, "PriceLevel is not correct")
        }
        XCTAssert(candleSymbol.exchange?.exchangeCode == exchangeCode, "Exchange is not correct")
    }
    // swiftlint:enable function_parameter_count

    func testCandleTypeEnum() throws {
        let fvalue = try? CandleType.parse("d")
        let svalue = try? CandleType.parse("Days")
        XCTAssert(fvalue == CandleType.day && svalue == CandleType.day, "Should be day enum")
    }

    func testEventFlags() throws {
        let string = "01/01/2021"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        let symbol = TimeSeriesSubscriptionSymbol(symbol: "AAPL{=1d}", date: dateFormatter.date(from: string)!)
        var endpoint: DXEndpoint? = try DXEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        try endpoint?.connect("demo.dxfeed.com:7300")
        let subscription = try endpoint?.getFeed()?.createSubscription(type)
        let beginEventsExp = expectation(description: "Begin events \(type)")
        let endEventsExp = expectation(description: "End events \(type)")
        let listener = AnonymousClass { anonymCl in
            anonymCl.callback = { events in
                if events.count > 0 {
                    events.forEach { event in

                        if event.type == .candle {
                            let candle = event.candle
                            if candle.eventFlags & Candle.snapshotBegin != 0 {
                                print(candle.toString())
                                beginEventsExp.fulfill()
                            }
                            if candle.eventFlags & Candle.snapshotEnd != 0 {
                                print(candle.toString())
                                endEventsExp.fulfill()
                            }
                        }
                    }
                }
            }
            return anonymCl
        }
        try subscription?.add(listener: listener)
        try subscription?.addSymbols(symbol)
        wait(for: [beginEventsExp, endEventsExp], timeout: 10)
        try? endpoint?.disconnect()
        try? endpoint?.closeAndAwaitTermination()
        endpoint = nil
        let sec = 5
        _ = XCTWaiter.wait(for: [expectation(description: "\(sec) seconds waiting")], timeout: TimeInterval(sec))
    }

    func testSnapshot() throws {
        let string = "01/01/2021"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        let startDate = dateFormatter.date(from: string)!
        let componentsLeftTime = Calendar.current.dateComponents([.weekOfMonth], from: startDate, to: Date())
        let symbol = TimeSeriesSubscriptionSymbol(symbol: "ETH/USD:GDAX{=1w}", date: startDate)
        var endpoint: DXEndpoint? = try DXEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        try endpoint?.connect("demo.dxfeed.com:7300")
        let subscription = try endpoint?.getFeed()?.createSubscription(type)
        let snapshotExpect = expectation(description: "Snapshot \(type)")
        snapshotExpect.assertForOverFulfill = false
        let updateExpect = expectation(description: "Incremental update \(type)")
        updateExpect.assertForOverFulfill = false
        let snapshotProcessor = SnapshotProcessor()
        let testDelegate = TestSnapshotDelegate()
        testDelegate.numberOfWeeks = componentsLeftTime.weekOfMonth
        testDelegate.wasSnapshotExpect = snapshotExpect
        testDelegate.wasUpdateExpect = updateExpect
        snapshotProcessor.add(testDelegate)
        try subscription?.add(listener: snapshotProcessor)
        try subscription?.addSymbols(symbol)
        wait(for: [snapshotExpect, updateExpect], timeout: 10)
        try? endpoint?.disconnect()
        try? endpoint?.closeAndAwaitTermination()
        endpoint = nil
    }

    func testCandleSymbols() {
        XCTAssert(CandlePeriod.day == CandlePeriod.valueOf(value: 1, type: .day))
        XCTAssert(CandleSymbol.valueOf("TEST123", [CandlePeriod.day]).toString() == "TEST123{=d}")
        XCTAssert(CandleSymbol.valueOf("TEST123", [CandlePeriod.valueOf(value: 2, type: .day)]).toString()
                  == "TEST123{=2d}")
        XCTAssert(CandleSymbol.valueOf("TEST123", [CandlePeriod.tick]).toString() == "TEST123")
        let testSymbol = try? CandleSymbol.valueOf("TEST123{=12d}")
        XCTAssert(testSymbol?.period?.type == .day && testSymbol?.period?.value == 12)
        XCTAssert(testSymbol == CandleSymbol.valueOf("TEST123", [CandlePeriod.valueOf(value: 12, type: .day)]))
        XCTAssert(CandleSymbol.valueOf("TEST1", [CandlePrice.ask]).toString() == "TEST1{price=ask}")
    }
}

private class TestSnapshotDelegate: SnapshotDelegate {
    var wasSnapshotExpect: XCTestExpectation?
    var wasUpdateExpect: XCTestExpectation?
    var wasSnapshot = false
    var numberOfWeeks: Int?
    func receiveEvents(_ events: [MarketEvent], isSnapshot: Bool) {
        if isSnapshot {
            if events.count < (numberOfWeeks ?? 0) - 1 || events.count > (numberOfWeeks ?? 0) + 1 {
                XCTAssert(false, "Snapshot size is incorrect")
            }
            wasSnapshotExpect?.fulfill()
            wasSnapshot = true
        }
        if !isSnapshot && wasSnapshot {
            wasUpdateExpect?.fulfill()
        }
    }
}
