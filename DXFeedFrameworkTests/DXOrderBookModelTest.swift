//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import XCTest
@testable import DXFeedFramework

final class DXOrderBookModelTest: XCTestCase {
    class TestOrderBookModelListener: OrderBookModelListener, Hashable {
        var expectation: XCTestExpectation?
        init(expectation: XCTestExpectation?) {
            self.expectation = expectation
        }

        func modelChanged() {
            expectation?.fulfill()
        }

        static func == (lhs: DXOrderBookModelTest.TestOrderBookModelListener, rhs: DXOrderBookModelTest.TestOrderBookModelListener) -> Bool {
            return lhs === rhs
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(stringReference(self))
        }
    }
    let symbol = "OBM1"
    let MMID = "NYSE"

    func testInit() throws {
        let bookModel = try OrderBookModel()
    }

    func testFilters() {
        let allValues = OrderBookModelFilter.allCases
        let allNative = allValues.map { filter in
            filter.toNative()
        }
        XCTAssertEqual(allNative.map { filter in
            OrderBookModelFilter.fromNative(native: filter)
        }, allValues)
    }


    func testLotSize() throws {
        let endpoint = try DXEndpoint.create(.localHub)
        let publisher = endpoint.getPublisher()
        guard let feed = endpoint.getFeed() else {
            XCTAssert(false, "Feed shouldn't be nil")
            return
        }
        let orderBookModel = try OrderBookModel()
        defer {
            _ = try? orderBookModel.close()
        }
        try orderBookModel.setSymbol(symbol)
        try orderBookModel.setLotSize(100)

        try orderBookModel.attach(feed: feed)
        guard let buyModel = orderBookModel.buyOrders else {
            XCTAssert(false, "BuyModel shouldn't be nil")
            return
        }
        guard let sellModel = orderBookModel.sellOrders else {
            XCTAssert(false, "SellModel shouldn't be nil")
            return
        }
        let listener = TestOrderBookModelListener(expectation: nil)
        try orderBookModel.add(listener: listener)

        do {
            listener.expectation = XCTestExpectation(description: "waiting composite orders")
            try publisher?.publish(events: [compositeBuy(1)])
            wait(for: [listener.expectation!], timeout: 1)
            let buyEvents = try buyModel.getEvents()
            XCTAssertEqual(buyEvents!.count, 1)
            XCTAssertEqual(buyEvents!.first?.order.size, 100)
        }

        do {
            listener.expectation = XCTestExpectation(description: "waiting regional buy orders")
            try publisher?.publish(events: [regionalBuy("Q", 2)])
            wait(for: [listener.expectation!], timeout: 1)
            let buyEvents = try buyModel.getEvents()
            XCTAssertEqual(buyEvents!.count, 1)
            XCTAssertEqual(buyEvents!.first?.order.size, 200)
        }

        do {
            listener.expectation = XCTestExpectation(description: "waiting aggregate buy orders")
            try publisher?.publish(events: [aggregateBuy(2, 3, "Q", MMID)])
            wait(for: [listener.expectation!], timeout: 1)
            let buyEvents = try buyModel.getEvents()
            XCTAssertEqual(buyEvents!.count, 1)
            XCTAssertEqual(buyEvents!.first?.order.size, 300)
        }

        do {
            listener.expectation = XCTestExpectation(description: "waiting order buy orders")
            try publisher?.publish(events: [orderBuy(3, 400, "Q", MMID)])
            wait(for: [listener.expectation!], timeout: 1)
            let buyEvents = try buyModel.getEvents()
            XCTAssertEqual(buyEvents!.count, 1)
            XCTAssertEqual(buyEvents!.first?.order.size, 400)
        }

        try orderBookModel.clear()
        
        try orderBookModel.setSymbol(symbol)
        

        do {
            listener.expectation = XCTestExpectation(description: "waiting composite orders")
            try publisher?.publish(events: [compositeBuy(1)])
            wait(for: [listener.expectation!], timeout: 1)
            let buyEvents = try buyModel.getEvents()
            XCTAssertEqual(buyEvents!.count, 1)
            XCTAssertEqual(buyEvents!.first?.order.size, 100)
        }


    }
    
    private func asserOrder(_ order: Order, _ scope: Scope, _ value: Double) {
        XCTAssertEqual(order.size, value)
        XCTAssertEqual(order.scope, scope)
    }

    private func compositeBuy(_ value: Double) -> Quote {
        return Quote(symbol).also(block: { quote in
            quote.bidPrice = value * 10
            quote.bidSize = value
        })
    }

    private func regionalBuy(_ exchange: Character, _ value: Double) -> Quote {
        return Quote(symbol).also(block: { quote in
            quote.bidPrice = value * 10.0
            quote.bidSize = value
            quote.eventSymbol = MarketEventSymbols.changeExchangeCode(symbol, exchange)!
        })
    }
    
    private func aggregateBuy(_ index: Long,
                              _ value: Double,
                              _ exchange: Character,
                              _ mmid: String) -> Order {
        return createOrder(Scope.aggregate, Side.buy, index, value, exchange, mmid)
    }


    private func orderBuy(_ index: Long,
                          _ value: Double,
                          _ exchange: Character,
                          _ mmid: String) -> Order {
        return createOrder(Scope.order, Side.buy, index, value, exchange, mmid)
    }

    private func createOrder(_ scope: Scope,
                             _ side: Side,
                             _ index: Long,
                             _ value: Double,
                             _ exchange: Character,
                             _ mmid: String) -> Order {
        let order = Order(symbol)
        order.scope = scope
        order.index = index
        order.orderSide = side
        order.price = value * 10.0
        order.size = value
        try? order.setExchangeCode(exchange)
        order.marketMaker = mmid
        return order
    }
}
