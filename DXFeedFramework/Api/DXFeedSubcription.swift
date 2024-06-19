//
//  DXFeedSubcription.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 30.05.23.
//

import Foundation

/// Subscription for a set of symbols and event types.
///
/// [Read it first Javadoc](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXFeedSubscription.html)
public class DXFeedSubcription {
    /// Subscription native wrapper.
    private let native: NativeSubscription
    /// List of event types associated with this ``DXFeedSubscription``
    fileprivate let events: Set<EventCode>
    /// A set listeners of events
    /// observers - typed list wrapper.
    private let listeners = ConcurrentSet<AnyHashable>()

    internal init(native: NativeSubscription?, events: [EventCode]) throws {
        if let native = native {
            self.native = native
        } else {
            throw NativeException.nilValue
        }
        self.events = Set(events)
    }
    /// Adds listener for events.
    /// Event lister can be added only when subscription is not producing any events.
    /// The subscription must be either empty (no symbols have been added)
    /// or not attached to any feed.
    /// This method does nothing if this subscription is closed.
    ///
    /// [Javadoc](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXFeedSubscription.html#addEventListener-com.dxfeed.api.DXFeedEventListener)
    /// - Throws: GraalException. Rethrows exception from Java.
    public func add<O>(observer: O) throws
    where O: DXEventListener,
          O: Hashable {
              try listeners.reader { [weak self] in
                  if $0.isEmpty {
                      try self?.native.addListener(self)
                  }
              }
              listeners.insert(observer)
          }
    /// Removes listener for events.
    ///
    /// [Javadoc](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXFeedSubscription.html#addEventListener-com.dxfeed.api.DXFeedEventListener-)
    public func remove<O>(observer: O)
    where O: DXEventListener,
          O: Hashable {
              listeners.remove(observer)
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

}

extension DXFeedSubcription: DXEventListener {
    public func receiveEvents(_ events: [MarketEvent]) {
        listeners.reader { items in
            items.compactMap { $0 as? DXEventListener }.forEach { $0.receiveEvents(events) }
        }
    }
}

extension DXFeedSubcription: Hashable {
    public static func == (lhs: DXFeedSubcription, rhs: DXFeedSubcription) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.events)
    }
}

extension DXFeedSubcription: IObservableSubscription {
    public func isClosed() -> Bool {
        return native.isClosed()
    }

    public var eventTypes: Set<EventCode> {
        return events
    }

    public func isContains(_ eventType: EventCode) -> Bool {
        return events.contains(eventType)
    }
}
