//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

/// Main entry class for dxFeed API.
///
/// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXFeed.html)
public class DXFeed {
    /// Feed native wrapper.
    private let native: NativeFeed

    internal var nativeFeed: NativeFeed {
        return native
    }

    deinit {
    }

    internal init(native: NativeFeed?) throws {
        if let native = native {
            self.native = native
        } else {
            throw ArgumentException.argumentNil
        }
    }
    /// Creates new subscription for a list of event types that is attached to this feed.
    ///
    /// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXFeed.html#createSubscription-java.lang.Class)
    /// - Parameters:
    ///     - types: The list of event types.
    /// - Returns: ``DXFeedSubscription``
    /// - Throws: ``GraalException``. Rethrows exception from Java., ``ArgumentException/argumentNil``
    public func createSubscription(_ types: [IEventType.Type]) throws -> DXFeedSubscription {
        return try DXFeedSubscription(native: native.createSubscription(types), types: types)
    }
    /// Creates new subscription for a one event type that is attached to this feed.
    ///
    /// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXFeed.html#createSubscription-java.lang.Class)
    /// - Parameters:
    ///     - type: event code
    /// - Returns: ``DXFeedSubscription``
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public func createSubscription(_ type: IEventType.Type) throws -> DXFeedSubscription {
        return try DXFeedSubscription(native: native.createSubscription(type), types: [type])
    }

    /// Creates new time series subscription for a single event type that is <i>attached</i> to this feed.
    /// For multiple event types in one subscription use
    /// ``createTimeSeriesSubscription(_:)-tuiu``
    /// This method creates new ``DXFeedTimeSeriesSubscription`` and invokes ``attach(subscription:)``.
    ///
    /// - Parameters:
    ///     - types: The list of ITimeSeriesEvent.
    /// - Returns: ``DXFeedSubscription``
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public func createTimeSeriesSubscription(_ types: [ITimeSeriesEvent.Type]) throws -> DXFeedTimeSeriesSubscription {
        return try DXFeedTimeSeriesSubscription(native: native.createTimeSeriesSubscription(types),
                                                types: types)
    }

    /// Creates new time series subscription for a single event type that is <i>attached</i> to this feed.
    /// For multiple event types in one subscription use
    /// ``createTimeSeriesSubscription(_:)-tuiu``
    /// This method creates new ``DXFeedTimeSeriesSubscription`` and invokes ``attach(subscription:)``.
    ///
    /// - Parameters:
    ///     - type:  type of ITimeSeriesEvent.
    /// - Returns: ``DXFeedSubscription``
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public func createTimeSeriesSubscription(_ type: ITimeSeriesEvent.Type) throws -> DXFeedTimeSeriesSubscription {
        return try DXFeedTimeSeriesSubscription(
            native: native.createTimeSeriesSubscription(type),
            types: [type])
    }
}

public extension DXFeed {

    /// Returns the last event for the specified event instance.
    ///
    /// This method works only for event types that implement ``ILastingEvent`` marker interface.
    /// This method **does not** make any remote calls to the uplink data provider.
    /// It just retrieves last received event from the local cache of this feed.
    /// - Parameters:
    ///    - type: Type of MarketEvent.
    /// - Returns: ``ILastingEvent``
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    func getLastEvent(type: MarketEvent) throws -> ILastingEvent? {
        return try native.getLastEvent(type: type)
    }

    /// Returns the last event for the specified event type and symbol if there is a subscription for it.
    /// This method works only for event types that implement ``ILastingEvent`` marker interface.
    /// This method **does not** make any remote calls to the uplink data provider.
    /// It just retrieves last received event from the local cache of this feed.
    /// The events are stored in the cache only if there is some
    /// attached ``DXFeedSubscription`` that is subscribed to the corresponding event type and symbol.
    func getLastEventIfSubscribed(type: IEventType.Type, symbol: Symbol) throws -> ILastingEvent? {
        return try native.getLastEventIfSubscribed(type: type, symbol: symbol)
    }

    /// Returns the last events for the specified list of event instances.
    ///
    /// This is a bulk version of  ``getLastEvent(type:)`` method.
    /// - Parameters:
    ///    - types:  The  list of MarketEvent.
    /// - Returns: The list of ``ILastingEvent``
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    func getLastEvents(types: [MarketEvent]) throws -> [ILastingEvent] {
        return try native.getLastEvents(types: types)
    }
}

public extension DXFeed {
    /// Attaches the given subscription to this feed. This method does nothing if the
    /// corresponding subscription is already attached to this feed.
    ///
    /// This feed publishes data to the attached subscription.
    /// - Parameters:
    ///    - subscription: The ``DXFeedSubscription``.
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    func attach(subscription: DXFeedSubscription) throws {
        try native.attach(subscription: subscription.nativeSubscription)
    }

    /// Detaches the given subscription from this feed. This method does nothing if the
    /// corresponding subscription is not attached to this feed.
    ///
    /// - Parameters:
    ///    - subscription: The ``DXFeedSubscription``.
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    func detach(subscription: DXFeedSubscription) throws {
        try native.detach(subscription: subscription.nativeSubscription)
    }
}
