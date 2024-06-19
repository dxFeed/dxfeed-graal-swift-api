//
//  DXFeedSubcription.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 30.05.23.
//

import Foundation

public class DXFeedSubcription {
    private let native: NativeSubscription
    fileprivate let events: Set<EventCode>
    private let listeners = ConcurrentSet<AnyHashable>()
    deinit {
    }

    internal init(native: NativeSubscription?, events: [EventCode]) throws {
        if let native = native {
            self.native = native
        } else {
            throw NativeException.nilValue
        }
        self.events = Set(events)
    }

    public func add<O>(_ observer: O)
    where O: DXEventListener,
          O: Hashable {
              listeners.reader { [weak self] in
                  if $0.isEmpty {
                      try? self?.native.addListener(self)
                  }
              }
              listeners.insert(observer)
          }

    public func remove<O>(_ observer: O)
    where O: DXEventListener,
          O: Hashable {
              listeners.remove(observer)
          }

    public func addSymbols(_ symbol: Symbol) throws {
        try native.addSymbols(symbol)
    }

    public func addSymbols(_ symbols: [Symbol]) throws {
        try native.addSymbols(symbols)
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
