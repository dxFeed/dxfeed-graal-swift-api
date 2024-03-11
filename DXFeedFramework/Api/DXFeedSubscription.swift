//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

/// Subscription for a set of symbols and event types.
///
/// [Read it first Javadoc](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXFeedSubscription.html)
public class DXFeedSubscription {
    /// Subscription native wrapper.
    private let native: NativeSubscription
    /// List of event types associated with this ``DXFeedSubscription``
    fileprivate let types: [IEventType.Type]
    /// A set listeners of events
    /// listeners - typed list wrapper.
    private let listeners = ConcurrentWeakHashTable<AnyObject>()

    /// - Throws: ``GraalException`` Rethrows exception from Java, ``ArgumentException/argumentNil``
    internal init(native: NativeSubscription?, types: [IEventType.Type]) throws {
        if let native = native {
            self.native = native
        } else {
            throw ArgumentException.argumentNil
        }
        self.types = types
    }
    /// Adds listener for events.
    /// Event lister can be added only when subscription is not producing any events.
    /// The subscription must be either empty (no symbols have been added)
    /// or not attached to any feed.
    /// This method does nothing if this subscription is closed.
    ///
    /// [Javadoc](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXFeedSubscription.html#addEventListener-com.dxfeed.api.DXFeedEventListener)
    /// - Throws: ``GraalException`` Rethrows exception from Java, ``ArgumentException/argumentNil``
    public func add<O>(listener: O) throws
    where O: DXEventListener,
          O: Hashable {
              try listeners.reader { [weak self] in
                  if $0.count == 0 {
                      try self?.native.addListener(self)
                  }
              }
              listeners.insert(listener)
          }
    /// Removes listener for events.
    ///
    /// [Javadoc](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXFeedSubscription.html#addEventListener-com.dxfeed.api.DXFeedEventListener-)
    public func remove<O>(listener: O)
    where O: DXEventListener,
          O: Hashable {
              listeners.remove(listener)
          }

    /// Adds the specified  symbol to the set of subscribed symbols.
    ///
    /// All registered event listeners will receive update on the last events for
    /// newly added symbol.
    ///
    /// [Javadoc](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXFeedSubscription.html#addSymbols-java.util.Collection-)
    /// - Parameters:
    ///   - symbol: One symbol
    /// - Throws: GraalException. Rethrows exception from Java.
    public func addSymbols(_ symbol: Symbol) throws {
        try native.addSymbols(symbol)
    }

    /// Adds the specified collection of symbols to the set of subscribed symbols.
    ///
    /// All registered event listeners will receive update on the last events for all
    /// newly added symbols.
    ///
    /// [Javadoc](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXFeedSubscription.html#addSymbols-java.util.Collection-)
    /// - Parameters:
    ///   - symbol: The collection of symbols.
    /// - Throws: GraalException. Rethrows exception from Java.
    public func addSymbols(_ symbols: [Symbol]) throws {
        try native.addSymbols(symbols)
    }

    /// Removes the specified collection of symbols from the set of subscribed symbols.
    ///
    ///  [Javadoc](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXFeedSubscription.html#removeSymbols-java.util.Collection-)
    /// - Parameters:
    ///   - symbol: The collection of symbols.
    /// - Throws: GraalException. Rethrows exception from Java.
    public func removeSymbols(_ symbols: [Symbol]) throws {
        try native.removeSymbols(symbols)
    }

    /// Changes the set of subscribed symbols so that it contains just the symbols from the specified collection.
    ///
    /// All registered event listeners will receive update on the last events for all
    /// newly added symbols.
    ///
    /// [Javadoc](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXFeedSubscription.html#setSymbols-java.util.Collection-)
    /// - Parameters:
    ///   - symbol: The collection of symbols.
    /// - Throws: GraalException. Rethrows exception from Java.
    public func setSymbols(_ symbols: [Symbol]) throws {
        try native.setSymbols(symbols)
    }

    /// Returns a set of subscribed symbols.
    ///
    /// - Returns: The collection of symbols.
    /// - Throws: GraalException. Rethrows exception from Java.
    public func getSymbols() throws -> [Symbol] {
        return try native.getSymbols()
    }
}

extension DXFeedSubscription: DXEventListener {
    public func receiveEvents(_ events: [MarketEvent]) {
        listeners.reader { items in
            let enumerator = items.objectEnumerator()
            while let listener = enumerator.nextObject() as? DXEventListener {
                listener.receiveEvents(events)
            }
        }
    }
}

extension DXFeedSubscription: Hashable {
    public static func == (lhs: DXFeedSubscription, rhs: DXFeedSubscription) -> Bool {
        return lhs === rhs
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.types.map { $0.type })
    }
}

extension DXFeedSubscription: IObservableSubscription {
    public func isClosed() -> Bool {
        return native.isClosed()
    }

    public var eventTypes: [IEventType.Type] {
        return types
    }

    public func isContains(_ eventType: IEventType.Type) -> Bool {
        return types.contains { type in
            type == eventType
        }
    }

    public func addChangeListener(_ listener: ObservableSubscriptionChangeListener) throws {
        try native.addChangeListener(listener)
    }

    public func removeChangeListener(_ listener: ObservableSubscriptionChangeListener) throws {
        try native.removeChangeListener(listener)
    }
}
