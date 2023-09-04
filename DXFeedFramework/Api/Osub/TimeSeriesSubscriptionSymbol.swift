//
//  TimeSeriesSubscriptionSymbol.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 01.06.23.
//

import Foundation

public class TimeSeriesSubscriptionSymbol: IndexedEventSubscriptionSymbol<AnyHashable> {
    let fromTime: Long
    public init(symbol: AnyHashable, fromTime: Long) {
        self.fromTime = fromTime
        super.init(symbol: symbol, source: IndexedEventSource.defaultSource)
    }

    convenience public init(symbol: AnyHashable, date: Date) {
        self.init(symbol: symbol, fromTime: Long(date.timeIntervalSince1970) * 1000)
    }

    static func == (lhs: TimeSeriesSubscriptionSymbol, rhs: TimeSeriesSubscriptionSymbol) -> Bool {
        return lhs === rhs || lhs.symbol == rhs.symbol
    }

    public var stringValue: String {
        return "\(symbol){fromTime=\(TimeUtil.toLocalDateString(millis: fromTime))}"
    }
}

extension TimeSeriesSubscriptionSymbol: CustomStringConvertible {
    public var description: String {
        return stringValue
    }
}
