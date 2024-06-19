//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
public class TimeSeriesSubscriptionSymbol: GenericIndexedEventSubscriptionSymbol<AnyHashable> {
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

    /// Initializes a new instance of the ``TimeSeriesSubscriptionSymbol`` class
    /// with a specified event symbol and from date
    ///
    /// - Parameters:
    ///   - symbol: The event ``Symbol``
    ///   - date: Date. Just for easing initialization with date object
    convenience public init(symbol: Symbol, date: Date) {
        self.init(symbol: symbol.stringValue, fromTime: Long(date.timeIntervalSince1970) * 1000)
    }

    static func == (lhs: TimeSeriesSubscriptionSymbol, rhs: TimeSeriesSubscriptionSymbol) -> Bool {
        return lhs === rhs || lhs.symbol == rhs.symbol
    }

    /// Custom symbol has to return string representation.
    public override var stringValue: String {
        return "\(symbol){fromTime=\((try? DXTimeFormat.defaultTimeFormat?.withMillis?.format(value: fromTime)) ?? "")}"
    }
}

extension TimeSeriesSubscriptionSymbol: CustomStringConvertible {
    public var description: String {
        return stringValue
    }
}
