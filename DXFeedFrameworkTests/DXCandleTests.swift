//
//  DXCandleTests.swift
//  DXFeedFrameworkTests
//
//  Created by Aleksey Kosylo on 13.07.23.
//

import XCTest
@testable import DXFeedFramework

final class DXCandleTests: XCTestCase {

    func testFetchingCandlesByString() throws {
//        let code = EventCode.candle
//        var endpoint: DXEndpoint? = try DXEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
//        try endpoint?.connect("demo.dxfeed.com:7300")
//        let subscription = try endpoint?.getFeed()?.createSubscription(code)
//        let receivedEventExp = expectation(description: "Received events \(code)")
//        receivedEventExp.assertForOverFulfill = false
//        subscription?.add(AnonymousClass { anonymCl in
//            anonymCl.callback = { events in
//                if events.count > 0 {
//                    events.forEach { event in
//                        print(event)
//                    }
//                    receivedEventExp.fulfill()
//                }
//            }
//            return anonymCl
//        })
//        try subscription?.addSymbols(TimeSeriesSubscriptionSymbol(symbol: "AAPL{=2d}", fromTime: 1660125159))
//        wait(for: [receivedEventExp], timeout: 10)
//        try? endpoint?.disconnect()
//        endpoint = nil
//        let sec = 5
//        _ = XCTWaiter.wait(for: [expectation(description: "\(sec) seconds waiting")], timeout: TimeInterval(sec))
    }

//    func testFetchingCandlesBySymbol() throws {
//        let code = EventCode.candle
//        var endpoint: DXEndpoint? = try DXEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
//        try endpoint?.connect("demo.dxfeed.com:7300")
//        let subscription = try endpoint?.getFeed()?.createSubscription(code)
//        let receivedEventExp = expectation(description: "Received events \(code)")
//        receivedEventExp.assertForOverFulfill = false
//        subscription?.add(AnonymousClass { anonymCl in
//            anonymCl.callback = { events in
//                if events.count > 0 {
//                    events.forEach { event in
//                        print(event)
//                    }
//                    receivedEventExp.fulfill()
//                }
//            }
//            return anonymCl
//        })
//        let symbol = try CandleSymbol.valueOf("AAPL&A{=3d}")
//        try subscription?.addSymbols(TimeSeriesSubscriptionSymbol(symbol: symbol, fromTime: 1660125159))
//        wait(for: [receivedEventExp], timeout: 10)
//        try? endpoint?.disconnect()
//        endpoint = nil
//        let sec = 5
//        _ = XCTWaiter.wait(for: [expectation(description: "\(sec) seconds waiting")], timeout: TimeInterval(sec))
//    }
//
//    func testParse() throws {
//        let candleSymbol = try CandleSymbol.valueOf("AAPL&A{=3d}")
//        XCTAssert(candleSymbol.baseSymbol == "AAPL", "Please check base symbol")
//        XCTAssert(candleSymbol.exchange?.exchangeCode == "A", "Please check exchange code")
//        let period = candleSymbol.period
//        XCTAssert(period?.type == .day && period?.value == 3, "Please check period")
//    }
//
//    func testParse2() throws {
//        func check(_ candleSymbol: CandleSymbol) {
//            XCTAssert(candleSymbol.baseSymbol == "AAPL", "Please check base symbol")
//            let period = candleSymbol.period
//            XCTAssert(period?.type == .day && period?.value == 1, "Please check period")
//            let session = candleSymbol.session
//            XCTAssert(session == .regular, "Please check base symbol")
//        }
//        check(try CandleSymbol.valueOf("AAPL{tho=true,=d}"))
//        check(try CandleSymbol.valueOf("AAPL{=d,tho=true}"))
//    }
//
//    func testParse3() throws{
//        let candleSymbol = try CandleSymbol.valueOf("AAPL{=3y,price=bid,tho=true,a=s,pl=1000.5}")
//        XCTAssert(candleSymbol.baseSymbol == "AAPL", "Please check base symbol")
//        let period = candleSymbol.period
//        XCTAssert(period?.type == .year && period?.value == 3, "Please check period")
//        XCTAssert(candleSymbol.price == .bid && period?.value == 3, "Please check price")
//        XCTAssert(candleSymbol.session == .regular, "Please check session")
//        XCTAssert(candleSymbol.alignment == .session, "Please check alignment")
//        XCTAssert(candleSymbol.priceLevel?.value == 1000.5, "Please check price level")
//    }

    func testCreationSymbol() throws {
        let exchange = CandleExchange.valueOf("A")
        let period = CandlePeriod.valueOf(value: 100, type: .day)
        let priceLevel = try CandlePriceLevel.valueOf(value: 999.35)
        let price = try CandlePrice.parse("mark")
        let session = try CandleSession.parse("true")
        let alignment = try CandleAlignment.parse("s")
        let symbol = CandleSymbol.valueOf("AAPL", [exchange, period, alignment, priceLevel, price, session])
        print(symbol.symbol)
    }

//    func testCandleTypeEnum() throws {
//        let fvalue = try? CandleType.parse("d")
//        let svalue = try? CandleType.parse("Days")
//        XCTAssert(fvalue == CandleType.day && svalue == CandleType.day, "Should be day enum")
//    }
}
