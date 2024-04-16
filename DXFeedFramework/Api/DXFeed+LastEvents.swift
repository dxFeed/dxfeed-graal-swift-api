//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation

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
        return try nativeFeed.getLastEvent(type: type)
    }

    /// Returns the last events for the specified list of event instances.
    ///
    /// This is a bulk version of  ``getLastEvent(type:)`` method.
    /// - Parameters:
    ///    - types:  The  list of MarketEvent.
    /// - Returns: The list of ``ILastingEvent``
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    func getLastEvents(types: [MarketEvent]) throws -> [ILastingEvent] {
        return try nativeFeed.getLastEvents(types: types)
    }
}

public extension DXFeed {
    /// Returns the last event for the specified event type and symbol if there is a subscription for it.
    ///
    /// This method works only for event types that implement ``ILastingEvent`` marker interface.
    /// This method **does not** make any remote calls to the uplink data provider.
    /// It just retrieves last received event from the local cache of this feed.
    /// The events are stored in the cache only if there is some
    /// attached ``DXFeedSubscription`` that is subscribed to the corresponding event type and symbol.
    /// - Parameters:
    ///    - type: The event type ``IEventType``.
    ///    - symbol: The ``Symbol``.
    /// - Returns: The list of ``ILastingEvent``
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    func getLastEventIfSubscribed(type: IEventType.Type, symbol: Symbol) throws -> ILastingEvent? {
        return try nativeFeed.getLastEventIfSubscribed(type: type, symbol: symbol)
    }

    // Returns a list of indexed events for the specified event type, symbol, and source
    /// if there is a subscription for it.
    ///
    /// This method works only for event types that implement ``IIndexedEvent``interface.
    /// This method **does not** make any remote calls to the uplink data provider.
    /// It just retrieves last received events from the local cache of this feed.
    /// The events are stored in the cache only if there is some
    /// attached ``DXFeedSubscription`` that is subscribed to the corresponding event type, symbol, and source.
    /// - Parameters:
    ///    - type: The event type ``IEventType``.
    ///    - symbol: The ``Symbol``.
    ///    - source: The ``IndexedEventSource``.
    /// - Returns: The list of ``IIndexedEvent``
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    func getIndexedEventsIfSubscribed(type: IEventType.Type,
                                      symbol: Symbol,
                                      source: IndexedEventSource) throws -> [IIndexedEvent]? {
        return try nativeFeed.getIndexedEventsIfSubscribed(type: type,
                                                       symbol: symbol,
                                                       source: source)
    }
}
