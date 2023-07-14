//
//  TimeSeriesSubscriptionSymbol.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 01.06.23.
//

import Foundation

class TimeSeriesSubscriptionSymbol<T>: IndexedEventSubscriptionSymbol<T> {
    let fromTime: Long
    init(symbol: T, fromTime: Long) {
        self.fromTime = fromTime
        super.init(symbol: symbol)

    }
}
#warning("TODO: implement correct erasing ")

class TimeSeriesSubscriptionSymbol1: TimeSeriesSubscriptionSymbol<Any> {
    override init(symbol: Any, fromTime: Long) {
        super.init(symbol: symbol, fromTime: fromTime)
    }
}
