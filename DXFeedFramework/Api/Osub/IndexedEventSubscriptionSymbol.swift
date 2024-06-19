//
//  IndexedEventSubscriptionSymbol.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 01.06.23.
//

import Foundation

class IndexedEventSubscriptionSymbol<T>: Symbol {
    let symbol: T
    init(symbol: T) {
        self.symbol = symbol
    }
}
