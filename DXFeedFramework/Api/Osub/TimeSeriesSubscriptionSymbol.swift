//
//  TimeSeriesSubscriptionSymbol.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 01.06.23.
//

import Foundation

class TimeSeriesSubscriptionSymbol: IndexedEventSubscriptionSymbol<Any> {
    let fromTime: Long
    init(symbol: Any, fromTime: Long) {
        self.fromTime = fromTime
        super.init(symbol: symbol)
    }
}
