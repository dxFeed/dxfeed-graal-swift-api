//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation


public class MarketDepthModel {
    let symbol: String
    let sources: [OrderSource]
    let feed: DXFeed

    var depthLimit: Int = 0

    let subscription: DXFeedSubscription

    let buyOrders = OrderSet(comparator: buyComparator)
    let sellOrders = OrderSet(comparator: sellComparator)
    var ordersByIndex = [Long: Order]()

    let aggregationPeriodMillis: Long = 1000
    
    let txModel: IndexedTxModel
    weak var listener: MarketDepthListener?

    public init(symbol: String,
                sources: [OrderSource],
                mode: TxMode,
                feed: DXFeed) throws {
        txModel = IndexedTxModel(mode: mode)

        self.symbol = symbol
        self.sources = sources
        self.feed = feed
        self.subscription = try feed.createSubscription(Order.self)

        txModel.setListener(self)
        try self.subscription.add(listener: txModel)
        if sources.count == 0 {
            try self.subscription.setSymbols([symbol])
        } else {
            let symbols = sources.map { source in
                IndexedEventSubscriptionSymbol(symbol: symbol, source: source)
            }
            try self.subscription.setSymbols(symbols)
        }
    }

    func setListener(_ listener: MarketDepthListener) {
        self.listener = listener
    }
}

extension MarketDepthModel: TxModelListener {
    func modelChanged(changes: IndexedTxModel.Changes) {
        if update(changes) {
            if changes.isSnapshot || aggregationPeriodMillis == 0 {
                // notify right now
            } else {
                // notify with delay
            }
        }
    }

    func notifyListeners() {
        if listener == nil {
            return
        }

        listener?.modelChanged(changes: OrderBook(buyOrders: getBuyOrders(), sellOrders: getSellOrders()))

//                taskScheduled.set(false);

    }

    func getBuyOrders() -> [Order] {
        return buyOrders.toList()
    }

    func getSellOrders() -> [Order] {
        return sellOrders.toList()
    }

    func update(_ changes: IndexedTxModel.Changes) -> Bool {
        if changes.isSnapshot {
            clearBySource(source: changes.source)
        }
        changes.events.forEach { order in
            let removed = ordersByIndex.removeValue(forKey: order.index)
            if let removed = removed {
                getOrderSetForOrder(removed).remove(removed)
            }
            if shallAdd(order) {
                ordersByIndex[order.index] = order
                getOrderSetForOrder(order).add(order)
            }
        }
        return isChanged()
    }

    func isChanged() -> Bool {
        return buyOrders.isChanged() || sellOrders.isChanged()
    }

    func clearBySource(source: IndexedEventSource) {
        ordersByIndex.removeIf(condition: { element in
            element.value.eventSource == source
        })
        buyOrders.clearBySource(source)
        sellOrders.clearBySource(source)
    }

    func getOrderSetForOrder(_ order: Order) -> OrderSet {
        if order.orderSide == .buy {
            buyOrders
        } else {
            sellOrders
        }
    }

    func shallAdd(_ order: Order) -> Bool {
        return order.hasSize() && (!order.isRemove())
    }
}
