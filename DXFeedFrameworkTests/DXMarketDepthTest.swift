//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import XCTest
@testable import DXFeedFramework

// swiftlint:disable type_body_length
// swiftlint:disable function_body_length
final class DXMarketDepthTest: XCTestCase, MarketDepthListener {

    func modelChanged(changes: DXFeedFramework.OrderBook) {
        if orderBook.buyOrders != changes.buyOrders {
            changesBuy += 1
        }
        if orderBook.sellOrders != changes.sellOrders {
            changesSell += 1
        }

        orderBook = changes
        expectation1?.fulfill()
    }

    let symbol = "INDEX-TEST"
    let source = OrderSource.defaultOrderSource!
    let bookSize = 100

    var endpoint: DXEndpoint!
    var feed: DXFeed!
    var publisher: DXPublisher!
    var expectation1: XCTestExpectation?
    var orderBook = OrderBook()
    var model: MarketDepthModel!
    var changesBuy = 0
    var changesSell = 0

    override func setUp() async throws {
        endpoint = try DXEndpoint.create(.localHub)
        feed = endpoint.getFeed()
        publisher = endpoint.getPublisher()
        model = try MarketDepthModel(symbol: symbol,
                                     sources: [source],
                                     aggregationPeriodMillis: 0,
                                     mode: .multiple,
                                     feed: feed,
                                     listener: self)

    }

    func testRemoveBySizeAndByFlags() throws {
        let order1 = try createOrder(index: 2, side: .buy, price: 3, size: 1, eventFlags: 0)
        let order2 = try createOrder(index: 1, side: .buy, price: 2, size: 1, eventFlags: 0)
        let order3 = try createOrder(index: 0, side: .buy, price: 1, size: 1, eventFlags: 0)
        try publisher.publish(events: [order1, order2, order3])
        expectation1 = expectation(description: "Events received")
        wait(for: [expectation1!], timeout: 1.0)
        XCTAssertEqual(orderBook.buyOrders.count, 3)
        XCTAssertEqual(orderBook.sellOrders.count, 0)

        XCTAssert(same(order1: order1, order2: orderBook.buyOrders[0]))
        XCTAssert(same(order1: order2, order2: orderBook.buyOrders[1]))
        XCTAssert(same(order1: order3, order2: orderBook.buyOrders[2]))

        try publisher.publish(events: [try createOrder(index: 2,
                                                       side: .buy,
                                                       price: 2,
                                                       size: Double.nan, eventFlags: 0)])
        expectation1 = expectation(description: "Events received")
        wait(for: [expectation1!], timeout: 1.0)
        XCTAssertEqual(orderBook.buyOrders.count, 2)
        XCTAssertEqual(orderBook.sellOrders.count, 0)
        XCTAssert(same(order1: order2, order2: orderBook.buyOrders[0]))

        try publisher.publish(events: [try createOrder(index: 1,
                                                       side: .buy,
                                                       price: 2,
                                                       size: Double.nan, eventFlags: Order.removeEvent)])
        expectation1 = expectation(description: "Events received")
        wait(for: [expectation1!], timeout: 1.0)
        XCTAssertEqual(orderBook.buyOrders.count, 1)
        XCTAssertEqual(orderBook.sellOrders.count, 0)
        XCTAssert(same(order1: order3, order2: orderBook.buyOrders[0]))

        try publisher.publish(events: [try createOrder(index: 0,
                                                       side: .buy,
                                                       price: 1,
                                                       size: 1,
                                                       eventFlags: Order.removeEvent | Order.snapshotEnd)])
        expectation1 = expectation(description: "Events received")
        wait(for: [expectation1!], timeout: 1.0)
        XCTAssertEqual(orderBook.buyOrders.count, 0)
        XCTAssertEqual(orderBook.sellOrders.count, 0)

        XCTAssertEqual(model.buyOrders.toList().count, 0)
    }

    func testOrderChangeSide() throws {
        let order1 = try createOrder(index: 0, side: .buy, price: 1, size: 1, eventFlags: 0)
        try publisher.publish(events: [order1])
        expectation1 = expectation(description: "Events received")
        wait(for: [expectation1!], timeout: 1.0)
        XCTAssertEqual(orderBook.buyOrders.count, 1)
        XCTAssertEqual(orderBook.sellOrders.count, 0)
        XCTAssert(same(order1: order1, order2: orderBook.buyOrders[0]))

        let order2 = try createOrder(index: 0, side: .sell, price: 1, size: 1, eventFlags: 0)
        try publisher.publish(events: [order2])
        expectation1 = expectation(description: "Events received")
        wait(for: [expectation1!], timeout: 1.0)
        XCTAssertEqual(orderBook.buyOrders.count, 0)
        XCTAssertEqual(orderBook.sellOrders.count, 1)
        XCTAssert(same(order1: order2, order2: orderBook.sellOrders[0]))
    }

    func testOrderPriorityAfterUpdate() throws {

        let bOrder1 = try createOrder(index: 0, side: .buy, price: 100, size: 1, eventFlags: 0)
        let bOrder2 = try createOrder(index: 1, side: .buy, price: 150, size: 1, eventFlags: 0)

        let sOrder1 = try createOrder(index: 3, side: .sell, price: 150, size: 1, eventFlags: 0)
        let sOrder2 = try createOrder(index: 2, side: .sell, price: 100, size: 1, eventFlags: 0)

        try publisher.publish(events: [bOrder1])
        expectation1 = expectation(description: "Events received")
        wait(for: [expectation1!], timeout: 1.0)
        XCTAssert(same(order1: bOrder1, order2: orderBook.buyOrders[0]))

        try publisher.publish(events: [bOrder2])
        expectation1 = expectation(description: "Events received")
        wait(for: [expectation1!], timeout: 1.0)
        XCTAssert(same(order1: bOrder2, order2: orderBook.buyOrders[0]))
        XCTAssert(same(order1: bOrder1, order2: orderBook.buyOrders[1]))

        try publisher.publish(events: [sOrder1])
        expectation1 = expectation(description: "Events received")
        wait(for: [expectation1!], timeout: 1.0)
        XCTAssert(same(order1: sOrder1, order2: orderBook.sellOrders[0]))

        try publisher.publish(events: [sOrder2])
        expectation1 = expectation(description: "Events received")
        wait(for: [expectation1!], timeout: 1.0)
        XCTAssert(same(order1: sOrder2, order2: orderBook.sellOrders[0]))
        XCTAssert(same(order1: sOrder1, order2: orderBook.sellOrders[1]))
    }

    func testMultipleUpdatesWithMixedSides() throws {
        let buyLowPrice = try createOrder(index: 0, side: .buy, price: 100, size: 1, eventFlags: 0)
        let buyHighPrice = try createOrder(index: 1, side: .buy, price: 200, size: 1, eventFlags: 0)
        let sellLowPrice = try createOrder(index: 2, side: .sell, price: 150, size: 1, eventFlags: 0)
        let sellHighPrice = try createOrder(index: 3, side: .sell, price: 250, size: 1, eventFlags: 0)

        try publisher.publish(events: [buyLowPrice, sellHighPrice, buyHighPrice, sellLowPrice])
        expectation1 = expectation(description: "Events received")
        wait(for: [expectation1!], timeout: 1.0)

        XCTAssert(same(order1: buyHighPrice, order2: orderBook.buyOrders[0]))
        XCTAssert(same(order1: sellLowPrice, order2: orderBook.sellOrders[0]))
    }

    func testDuplicateOrderIndexUpdatesExistingOrder() throws {
        let originalIndexOrder = try createOrder(index: 0, side: .buy, price: 100, size: 1, eventFlags: 0)
        let duplicateIndexOrder = try createOrder(index: 0, side: .buy, price: 150, size: 1, eventFlags: 0)

        try publisher.publish(events: [originalIndexOrder, duplicateIndexOrder])
        expectation1 = expectation(description: "Events received")
        wait(for: [expectation1!], timeout: 1.0)
        XCTAssertEqual(orderBook.buyOrders.count, 1)
        XCTAssert(same(order1: duplicateIndexOrder, order2: orderBook.buyOrders[0]))
    }

    func testEnforceEntryLimit() throws {
        model.setDepthLimit(3)

        try publisher.publish(events: [try createOrder(index: 0, side: .buy, price: 5, size: 1, eventFlags: 0),
                                       try createOrder(index: 1, side: .buy, price: 4, size: 1, eventFlags: 0),
                                       try createOrder(index: 2, side: .buy, price: 3, size: 1, eventFlags: 0)])

        expectation1 = expectation(description: "Events received0")
        expectation1?.assertForOverFulfill = false
        wait(for: [expectation1!], timeout: 1.0)

        try publisher.publish(events: [try createOrder(index: 3,
                                                       side: .buy,
                                                       price: 2,
                                                       size: 1,
                                                       eventFlags: 0)]) // outside limit
        expectation1 = expectation(description: "Events received1")
        expectation1?.isInverted = true
        wait(for: [expectation1!], timeout: 0.1)

        try publisher.publish(events: [try createOrder(index: 4,
                                                       side: .buy,
                                                       price: 1,
                                                       size: 1,
                                                       eventFlags: 0)]) // outside limit
        expectation1 = expectation(description: "Events received2")
        expectation1?.isInverted = true
        wait(for: [expectation1!], timeout: 0.1)

        try publisher.publish(events: [try createOrder(index: 4,
                                                       side: .buy,
                                                       price: 1,
                                                       size: 2,
                                                       eventFlags: 0)]) // modify outside limit
        expectation1 = expectation(description: "Events received3")
        expectation1?.isInverted = true
        wait(for: [expectation1!], timeout: 0.1)

        try publisher.publish(events: [try createOrder(index: 3,
                                                       side: .buy,
                                                       price: 2,
                                                       size: .nan,
                                                       eventFlags: 0)]) // remove outside limit
        expectation1 = expectation(description: "Events received4")
        expectation1?.isInverted = true
        wait(for: [expectation1!], timeout: 0.1)

        try publisher.publish(events: [try createOrder(index: 2,
                                                       side: .buy,
                                                       price: 3,
                                                       size: 2,
                                                       eventFlags: 0)]) // update in limit
        expectation1 = expectation(description: "Events received5")
        expectation1?.assertForOverFulfill = false
        wait(for: [expectation1!], timeout: 1.0)

        try publisher.publish(events: [try createOrder(index: 1,
                                                       side: .buy,
                                                       price: 3,
                                                       size: .nan,
                                                       eventFlags: 0)]) // remove in limit
        expectation1 = expectation(description: "Events received6")
        wait(for: [expectation1!], timeout: 1.0)

        model.setDepthLimit(0)
        expectation1 = nil

        try publisher.publish(events: [try createOrder(index: 4,
                                                       side: .buy,
                                                       price: 1,
                                                       size: 3,
                                                       eventFlags: 0)])
        expectation1 = expectation(description: "Events received7")
        wait(for: [expectation1!], timeout: 1.0)
        XCTAssertEqual(orderBook.buyOrders.count, 3)

        try publisher.publish(events: [try createOrder(index: 8,
                                                       side: .sell,
                                                       price: 1,
                                                       size: 3,
                                                       eventFlags: 0)])
        expectation1 = expectation(description: "Events received8")
        expectation1?.assertForOverFulfill = false
        wait(for: [expectation1!], timeout: 1.0)
        XCTAssertEqual(orderBook.buyOrders.count, 3)
        XCTAssertEqual(orderBook.sellOrders.count, 1)

        model.setDepthLimit(1)
        expectation1 = nil

        try publisher.publish(events: [try createOrder(index: 0, side: .buy, price: 2, size: 1, eventFlags: 0),
                                       try createOrder(index: 1, side: .buy, price: 2, size: 1, eventFlags: 0)])
        expectation1 = expectation(description: "Events received9")
        expectation1?.assertForOverFulfill = false
        wait(for: [expectation1!], timeout: 1.0)
    }

    func testStressBuySellOrders() throws {
        var book = [Order?](repeatElement(nil,
                                          count: bookSize))
        var expectedBuy = 0
        var expectedSell = 0
        for position in 0..<10000 {
            let index = Int.random(in: 0..<bookSize)
            let size = Int.random(in: 1..<10)
            // Note: every 1/10 order will have size == 0 and will "remove"
            let order = try createOrder(index: Int64(index),
                                        side: Bool.random() ? .buy : .sell,
                                        price: Double(size * 10),
                                        size: Double(size),
                                        eventFlags: 0)
            order.scope = .order
            let old = book[Int(index)]
            book[index] = order
            let deltaBuy = oneIfBuy(order) - oneIfBuy(old)
            let deltaSell = oneIfSell(order) - oneIfSell(old)
            expectedBuy += deltaBuy
            expectedSell += deltaSell
            try publisher.publish(events: [order])
        }
        wait(for: [expectation(for: NSPredicate(format: "buyOrdersSize = %d", expectedBuy),
                               evaluatedWith: self,
                               handler: nil),
                   expectation(for: NSPredicate(format: "sellOrdersSize = %d", expectedSell),
                               evaluatedWith: self,
                               handler: nil)],
             timeout: 5)
        changesBuy = 0
        changesSell = 0
        // now send "empty snapshot"
        let order = try createOrder(index: 0,
                                    side: .undefined,
                                    price: 0,
                                    size: 0,
                                    eventFlags: Order.removeEvent | Order.snapshotEnd | Order.snapshotBegin)
        order.scope = .order
        try publisher.publish(events: [order])
        wait(for: [expectation(for: NSPredicate(format: "buyOrdersSize = %d", 0),
                               evaluatedWith: self,
                               handler: nil),
                   expectation(for: NSPredicate(format: "sellOrdersSize = %d", 0),
                               evaluatedWith: self,
                               handler: nil)],
             timeout: 5)
        XCTAssertEqual(expectedBuy > 0 ? 1 : 0, changesBuy)
        XCTAssertEqual(expectedSell > 0 ? 1 : 0, changesSell)
    }

    func testStressSources() throws {
        let sources = Array(try OrderSource.publishable(eventType: Order.self).prefix(12))
        model = try MarketDepthModel(symbol: symbol,
                                     sources: sources,
                                     aggregationPeriodMillis: 0,
                                     mode: .multiple,
                                     feed: feed,
                                     listener: self)

        var expectedBuy = 0
        var expectedSell = 0

        var books = [Int: [Order?]]()
        sources.forEach { source in
            books[source.identifier] = [Order?](repeatElement(nil,
                                                              count: bookSize))
        }
        for _ in 0..<10000 {
            let index = Int.random(in: 0..<bookSize)
            let size = Int.random(in: 1..<10)
            // Note: every 1/10 order will have size == 0 and will "remove"
            let order = try createOrder(index: Int64(index),
                                        side: Bool.random() ? .buy : .sell,
                                        price: Double(size * 10),
                                        size: Double(size),
                                        eventFlags: 0)
            order.scope = .order
            let source = sources[Int.random(in: 0..<sources.count)]
            order.eventSource = source
            var book = books[source.identifier]!
            let old = book[Int(index)]
            book[index] = order
            books[source.identifier] = book
            let deltaBuy = oneIfBuy(order) - oneIfBuy(old)
            let deltaSell = oneIfSell(order) - oneIfSell(old)
            expectedBuy += deltaBuy
            expectedSell += deltaSell
            try publisher.publish(events: [order])
        }
        wait(for: [expectation(for: NSPredicate(format: "buyOrdersSize = %d", expectedBuy),
                               evaluatedWith: self,
                               handler: nil),
                   expectation(for: NSPredicate(format: "sellOrdersSize = %d", expectedSell),
                               evaluatedWith: self,
                               handler: nil)],
             timeout: 5)

        changesBuy = 0
        changesSell = 0
        // Now remove orders from all books in random order
        let allOrders = books.flatMap { _, value in
            value.compactMap { order in
                order
            }
        }.compactMap { order in
            let newOrder = try? createOrder(index: order.index,
                                            side: .undefined,
                                            price: 0,
                                            size: 0,
                                            eventFlags: Order.removeEvent)
            newOrder?.scope = .order
            return newOrder
        }
        try publisher.publish(events: allOrders)
        wait(for: [expectation(for: NSPredicate(format: "buyOrdersSize = %d", 0),
                               evaluatedWith: self,
                               handler: nil),
                   expectation(for: NSPredicate(format: "sellOrdersSize = %d", 0),
                               evaluatedWith: self,
                               handler: nil)],
             timeout: 5)
        XCTAssertEqual(expectedBuy > 0 ? sources.count : 0, changesBuy)
        XCTAssertEqual(expectedSell > 0 ? sources.count : 0, changesSell)

    }

    func oneIfBuy(_ order: Order?) -> Int {
        guard let order = order else {
            return 0
        }
        return (order.orderSide == .buy && order.size != 0) ? 1 : 0
    }

    func oneIfSell(_ order: Order?) -> Int {
        guard let order = order else {
            return 0
        }
        return (order.orderSide == .sell && order.size != 0) ? 1 : 0
    }

    func same(order1: Order, order2: Order?) -> Bool {
        guard let order2 = order2 else {
            return false
        }
        return order1.index == order2.index &&
        order1.orderSide == order2.orderSide &&
        order1.price == order2.price &&
        order1.size == order2.size &&
        order1.eventFlags == order2.eventFlags
    }

    func createOrder(index: Int64,
                     side: Side,
                     price: Double,
                     size: Double,
                     eventFlags: Int32) throws -> Order {
        let order1 = Order(symbol)
        try order1.setIndex(index)
        order1.orderSide = side
        order1.price = price
        order1.size = size
        order1.eventFlags = eventFlags
        return order1
    }
}

extension DXMarketDepthTest {
    @objc override func value(forKey key: String) -> Any? {
        switch key {
        case "buyOrdersSize":
            return orderBook.buyOrders.count
        case "sellOrdersSize":
            return orderBook.sellOrders.count
        default:
            fatalError("\(self) doesn't support \(key)")
        }
    }
}
// swiftlint:enable type_body_length
// swiftlint:enable function_body_length
