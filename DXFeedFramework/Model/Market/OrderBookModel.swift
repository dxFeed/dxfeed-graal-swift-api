//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation

/// Model for convenient Order Book management.
///
/// This class handles all snapshot and transaction logic of ``Order`` event class and
/// arranges incoming orders into a lists of  ``buyOrders`` and
/// ``sellOrders`` that are, in turn, arranged by price, so that
///  the first element of the list (at index 0) is at the top of the corresponding side of the book.
///  
///  Users of order book model only see the order book in a consistent state. This model delays incoming events which
/// are part of incomplete snapshot or ongoing transaction until snapshot is complete or transaction has ended.
/// These pending events cannot be seen neither via get methods of buy/sell order lists nor via listener calls, and so
/// ``IIndexedEvent/eventFlags`` of orders in the model are set to zero.
/// The eventFlags are only used and must be taken into account when processing orders directly via low-level ``DXFeedSubscription class.
public class OrderBookModel {
    let native: NativeOrderBookModel

    private let listeners = ConcurrentWeakHashTable<AnyObject>()

    /// Creates new model. This model is not attached to any feed, not subscribed to any symbol,
    /// and has filter set by default to {@link OrderBookModelFilter#ALL}.
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public init() throws {
        native = try NativeOrderBookModel()
    }

    /// Attaches model to the specified feed.
    /// - Parameters:
    ///   - feed: The feed to attach to.
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public func attach(feed: DXFeed) throws {
        try native.attach(feed: feed.nativeFeed)
    }

    /// Detaches model from the specified feed.
    /// - Parameters:
    ///   - feed: The feed to detach from.
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public func detach(feed: DXFeed) throws {
        try native.detach(feed: feed.nativeFeed)
    }

    /// Closes this model and makes it permanently detached.
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public func close() throws {
        try native.close()
    }

    /// Clears subscription symbol and, subsequently, all events in this model.
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public func clear() throws {
        try native.clear()
    }

    /// Returns filter for the model. This filter specifies which order events are shown in the book.
    /// - Returns: ``OrderBookModelFilter``
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public func getFilter() throws -> OrderBookModelFilter {
        try native.getFilter()
    }

    /// Sets the specified filter to the model.
    /// - Parameters:
    ///   - filter: The model filter.
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public func setFilter(_ filter: OrderBookModelFilter) throws {
        try native.setFilter(filter)
    }

    /// Returns order book symbol, or {@code null} for empty subscription.
    /// - Returns: order book symbol
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public func getSymbol() throws -> String? {
        try native.getSymbol()
    }

    /// Sets symbol for the order book to subscribe for.
    /// - Parameters:
    ///   - symbol: order book symbol. Use null for to unsubscribe.
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public func setSymbol(_ symbol: String?) throws {
        try native.setSymbol(symbol)
    }

    /// Returns lot size. Lot size is a multiplier applied to ``Scope/composite``
    /// - Returns: lot size.
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public func getLotSize() throws -> Int32 {
        try native.getLotSize()
    }

    /// Sets the lot size.
    /// - Parameters:
    ///   - size: lot size multiplier.
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public func setLotSize(_ size: Int32) throws {
        try native.setLotSize(size)
    }

    /// Returns the view of bid side (buy orders) of the order book.
    /// - Returns: ``ObservableListModel``.
    public lazy var buyOrders: ObservableListModel? = {
        if let native = try? native.getBuyOrders() {
            return ObservableListModel(native: native)
        } else {
            return nil
        }
    }()

    /// Returns the view of offer side (sell orders) of the order book.
    /// - Returns: ``ObservableListModel``.
    public lazy var sellOrders: ObservableListModel? = {
        if let native = try? native.getSellOrders() {
            return ObservableListModel(native: native)
        } else {
            return nil
        }
    }()

    /// Adds a listener to this order book model.
    /// - Parameters:
    ///   - listener: ``OrderBookModelListener``.
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public func add<O>(listener: O) throws
    where O: OrderBookModelListener,
          O: Hashable {
              try listeners.reader { [weak self] in
                  if $0.count == 0 {
                      try self?.native.addListener(self)
                  }
              }
              listeners.insert(listener)
          }

    /// Removes a listener from this order book model.
    /// - Parameters:
    ///   - listener: ``OrderBookModelListener``.
    public func remove<O>(listener: O)
    where O: OrderBookModelListener,
          O: Hashable {
              listeners.remove(listener)
          }
}

extension OrderBookModel: OrderBookModelListener {
    public func modelChanged() {
        listeners.reader { items in
            let enumerator = items.objectEnumerator()
            while let listener = enumerator.nextObject() as? OrderBookModelListener {
                listener.modelChanged()
            }
        }
    }
}
