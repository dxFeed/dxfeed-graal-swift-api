//
//  IndexedEventSubscriptionSymbol.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 01.06.23.
//

import Foundation

class IndexedEventSubscriptionSymbol<T: Equatable>: Symbol {
    let symbol: T
    let source: IndexedEventSource
    init(symbol: T, source: IndexedEventSource) {
        self.symbol = symbol
        self.source = source
    }

    func toString() -> String {
        return "\(symbol)source=\(source.toString())"
    }
}

extension IndexedEventSubscriptionSymbol: Equatable {
    static func == (lhs: IndexedEventSubscriptionSymbol<T>, rhs: IndexedEventSubscriptionSymbol<T>) -> Bool {
        return lhs === rhs || (lhs.symbol == rhs.symbol && lhs.source == rhs.source)
    }
}
