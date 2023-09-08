//
//  TimeSeriesSubscriptionSymbol.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 01.06.23.
//

import Foundation
/// Represents subscription to time-series of events.
///
/// Instances of this class can be used with ``DXFeedSubcription`` to specify subscription
/// for time series events from a specific time. By default, subscribing to time-series events by
/// their event symbol object, the subscription is performed to a stream of new events as they happen only.
///
/// [Javadoc](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/osub/TimeSeriesSubscriptionSymbol.html)
///
/// `T`: The type of event symbol.
public class TimeSeriesSubscriptionSymbol: IndexedEventSubscriptionSymbol<AnyHashable> {
    let fromTime: Long
    /// Initializes a new instance of the ``TimeSeriesSubscriptionSymbol`` class
    /// with a specified event symbol and from time in milliseconds since Unix epoch.
    ///
    /// - Parameters:
    ///   - symbol: The event symbol.
    ///   - fromTime: The from time is measured in milliseconds between the current time and midnight, January 1, 1970 UTC.
    public init(symbol: AnyHashable, fromTime: Long) {
        self.fromTime = fromTime
        super.init(symbol: symbol, source: IndexedEventSource.defaultSource)
    }
    /// Initializes a new instance of the ``TimeSeriesSubscriptionSymbol`` class
    /// with a specified event symbol and from date
    ///
    /// - Parameters:
    ///   - symbol: The event symbol.
    ///   - date: Date. Just for easing initialization with date object
    convenience public init(symbol: AnyHashable, date: Date) {
        self.init(symbol: symbol, fromTime: Long(date.timeIntervalSince1970) * 1000)
    }

    static func == (lhs: TimeSeriesSubscriptionSymbol, rhs: TimeSeriesSubscriptionSymbol) -> Bool {
        return lhs === rhs || lhs.symbol == rhs.symbol
    }

    /// Custom symbol has to return string representation.
    override public var stringValue: String {
        return "\(symbol){fromTime=\(TimeUtil.toLocalDateString(millis: fromTime))}"
    }
}

extension TimeSeriesSubscriptionSymbol: CustomStringConvertible {
    public var description: String {
        return stringValue
    }
}
