//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation

/// Extends ``DXFeedSubcription`` to conveniently subscribe to time-series of
/// events for a set of symbols and event types. 
///
/// This class decorates symbols
/// that are passed to xxxSymbols methods in ``DXFeedSubcription``
/// by wrapping them into ``TimeSeriesSubscriptionSymbol`` instances with
/// the current value of fromTime property.
///
///  Only events that implement ``ITimeSeriesEvent`` interface can be
/// subscribed to with DXFeedTimeSeriesSubscription``.
public class DXFeedTimeSeriesSubscription: DXFeedSubcription {
    /// Subscription native wrapper.
    private let native: NativeTimeSeriesSubscription?

    /// - Throws: ``GraalException`` Rethrows exception from Java, ``ArgumentException/argumentNil``
    internal init(native: NativeTimeSeriesSubscription?, events: [EventCode]) throws {
        if let native = native {
            self.native = native
        } else {
            throw ArgumentException.argumentNil
        }
        try super.init(native: native?.subscription, events: events)
    }

    /// Set the earliest timestamp from which time-series of events shall be received.
    /// The timestamp is in milliseconds from midnight, January 1, 1970 UTC.
    ///
    /// - Parameters:
    ///   - fromTime: fromTime the timestamp
    /// - Throws: ``GraalException`` Rethrows exception from Java, ``ArgumentException/argumentNil``
    func set(fromTime: Long) throws {
        try native?.set(fromTime: fromTime)
    }
}
