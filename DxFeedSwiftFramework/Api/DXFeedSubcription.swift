//
//  DXFeedSubcription.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 30.05.23.
//

import Foundation

class DXFeedSubcription {
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

    func add<O>(_ observer: O)
    where O: DXEventListener,
          O: Hashable {
              listeners.reader { [weak self] in
                  if $0.isEmpty {
                      try? self?.native.addListener(self)
                  }
              }
              listeners.insert(observer)
          }

    func remove<O>(_ observer: O)
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
    func receiveEvents(_ events: [AnyObject]) {

    }
}

extension DXFeedSubcription: Hashable {
    static func == (lhs: DXFeedSubcription, rhs: DXFeedSubcription) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.events)
    }
}
