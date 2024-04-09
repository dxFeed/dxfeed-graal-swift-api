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
    /// [Javadoc](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXFeed.html#createSubscription-java.lang.Class)
    /// - Parameters:
    ///     - types: The list of event types.
    /// - Returns: ``DXFeedSubscription``
    /// - Throws: ``GraalException``. Rethrows exception from Java., ``ArgumentException/argumentNil``
    public func createSubscription(_ types: [IEventType.Type]) throws -> DXFeedSubscription {
        return try DXFeedSubscription(native: native.createSubscription(types), types: types)
    }
    /// Creates new subscription for a one event type that is attached to this feed.
    ///
    /// [Javadoc](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXFeed.html#createSubscription-java.lang.Class)
    /// - Parameters:
    ///     - type: event code
    /// - Returns: ``DXFeedSubscription``
    /// - Throws: GraalException. Rethrows exception from Java.
    public func createSubscription(_ type: IEventType.Type) throws -> DXFeedSubscription {
        return try DXFeedSubscription(native: native.createSubscription(type), types: [type])
    }

    /// Creates new time series subscription for a single event type that is <i>attached</i> to this feed.
    /// For multiple event types in one subscription use
    /// ``createTimeSeriesSubscription(_:)-tuiu``
    /// This method creates new ``DXFeedTimeSeriesSubscription`` and invokes ``attachSubscription``.
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
    /// This method creates new ``DXFeedTimeSeriesSubscription`` and invokes ``attachSubscription``.
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
    ///  Requests the last event for the specified event type and symbol.
    ///
    /// This method works only for event types that implement ``ILastingEvent`` marker interface.
    /// This method requests the data from the the uplink data provider,
    /// creates new event of the specified ``IEventType``,
    /// and Success the resulting task with this event.
    /// - Parameters:
    ///    - type:  ``IEventType``.
    ///    - symbol: ``Symbol``
    /// - Returns: Task
    @available(iOS 13.0, *)
    @available(macOS 10.15, *)
    func getLastEvent(type: IEventType.Type,
                      symbol: Symbol) -> Task<MarketEvent?, Error> {
        let task = Task {
            let defaultValue: MarketEvent? = nil
            if Task.isCancelled {
                return defaultValue
            }
            let nativePromise = try native.getLastEventPromise(type: type,
                                                               symbol: symbol)
            let promise = Promise(native: nativePromise)
            while !promise.hasResult() {
                try? await Task.sleep(nanoseconds: 100_000_000)
                if Task.isCancelled {
                    return defaultValue
                }
            }
            return try promise.getResult()
        }
        return task
    }

    ///  Requests the last event for the specified event type and symbol.
    ///
    /// This method works only for event types that implement ``ILastingEvent`` marker interface.
    /// This method requests the data from the the uplink data provider,
    /// creates new event of the specified ``IEventType``,
    /// and complete the resulting promis the resulting promise with this event.
    /// - Parameters:
    ///    - type:  ``IEventType``.
    ///    - symbol: ``Symbol``
    /// - Returns: ``Promise``
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    func getLastEventPromise(type: IEventType.Type, symbol: Symbol) throws -> Promise? {
        let nativePromise = try native.getLastEventPromise(type: type, symbol: symbol)
        return Promise(native: nativePromise)
    }

    ///  Requests the last events for the specified event type and a collection of symbols.
    ///
    /// This method works only for event types that implement ``ILastingEvent`` marker interface.
    /// This method requests the data from the the uplink data provider,
    /// creates new events of the specified ``IEventType``,
    /// and complete the resulting promise with these events.
    /// - Parameters:
    ///    - type:  ``IEventType``.
    ///    - symbol: The list of ``Symbol``
    /// - Returns: The list of ``Promise``
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    func getLastEventPromises(type: IEventType.Type, symbols: [Symbol]) throws -> [Promise]? {
        let nativePromises = try native.getLastEventPromises(type: type, symbols: symbols)
        return nativePromises?.map({ promise in
            Promise(native: promise)
        })
    }

    ///  Requests a list of indexed events for the specified event type, symbol, and source.
    ///
    /// This method works only for event types that implement ``IndexedEventSource`` marker interface.
    /// This method requests the data from the the uplink data provider,
    /// creates a list of events of the specified ``IEventType``,
    /// and Success the resulting task with this list.
    /// The events are ordered by ``IIndexedEvent/index`` in the list.
    /// - Parameters:
    ///    - type:  ``IEventType``.
    ///    - symbol: ``Symbol``
    ///    - source: ``IndexedEventSource``
    /// - Returns: Task
    @available(iOS 13.0, *)
    @available(macOS 10.15, *)
    func getIndexedEvents(type: IEventType.Type,
                          symbol: Symbol,
                          source: IndexedEventSource) -> Task<[MarketEvent]?, Error> {
        let task = Task {
            let defaultValue: [MarketEvent]? = nil
            if Task.isCancelled {
                return defaultValue
            }
            let nativePromise = try native.getIndexedEventsPromise(type: type,
                                                                   symbol: symbol,
                                                                   source: source)
            let promise = Promise(native: nativePromise)
            while !promise.hasResult() {
                try? await Task.sleep(nanoseconds: 100_000_000)
                if Task.isCancelled {
                    return defaultValue
                }
            }
            return try promise.getResults()
        }
        return task
    }

    ///  Requests a list of indexed events for the specified event type, symbol, and source.
    ///
    /// This method works only for event types that implement ``IndexedEventSource`` marker interface.
    /// This method requests the data from the the uplink data provider,
    /// creates a list of events of the specified ``IEventType``,
    /// and complete  the resulting promise with this list.
    /// The events are ordered by ``IIndexedEvent/index`` in the list.
    /// - Parameters:
    ///    - type:  ``IEventType``.
    ///    - symbol: ``Symbol``
    ///    - source: ``IndexedEventSource``
    /// - Returns: ``Promise``
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    func getIndexedEventsPromise(type: IEventType.Type, symbol: Symbol, source: IndexedEventSource) throws -> Promise? {
        let nativePromise = try native.getIndexedEventsPromise(type: type, symbol: symbol, source: source)
        return Promise(native: nativePromise)
    }

    /// Requests time series of events for the specified event type, symbol, and a range of time.
    ///
    /// This method works only for event types that implement ``ITimeSeriesEvent`` interface.
    /// This method requests the data from the the uplink data provider,
    /// creates a list of events of the specified ``IEventType``,
    /// and Success the resulting task with this list.
    /// The events are ordered by ``ITimeSeriesEvent/time``in the list.
    /// - Parameters:
    ///    - type:  ``IEventType``.
    ///    - symbol: ``Symbol``
    ///    - fromTime: the time, inclusive, to request events from ``ITimeSeriesEvent/time``
    ///    - toTime: the time, inclusive, to request events to ``ITimeSeriesEvent/time``
    /// - Returns: Task
    @available(iOS 13.0, *)
    @available(macOS 10.15, *)
    func getTimeSeries(type: IEventType.Type,
                       symbol: Symbol,
                       fromTime: Long,
                       toTime: Long) -> Task<[MarketEvent]?, Error> {
        let task = Task {
            let defaultValue: [MarketEvent]? = nil
            if Task.isCancelled {
                return defaultValue
            }
            let nativePromise = try native.getTimeSeriesPromise(type: type,
                                                                symbol: symbol,
                                                                fromTime: fromTime,
                                                                toTime: toTime)
            let promise = Promise(native: nativePromise)
            while !promise.hasResult() {
                try? await Task.sleep(nanoseconds: 100_000_000)
                if Task.isCancelled {
                    return defaultValue
                }
            }
            return try promise.getResults()
        }
        return task
    }

    /// Requests time series of events for the specified event type, symbol, and a range of time.
    ///
    /// This method works only for event types that implement ``ITimeSeriesEvent`` interface.
    /// This method requests the data from the the uplink data provider,
    /// creates a list of events of the specified ``IEventType``,
    /// and complete the resulting promise with this list.
    /// The events are ordered by ``ITimeSeriesEvent/time``in the list.
    /// - Parameters:
    ///    - type:  ``IEventType``.
    ///    - symbol: ``Symbol``
    ///    - fromTime: the time, inclusive, to request events from ``ITimeSeriesEvent/time``
    ///    - toTime: the time, inclusive, to request events to ``ITimeSeriesEvent/time``
    /// - Returns: Task
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    func getTimeSeriesPromise(type: IEventType.Type, symbol: Symbol, fromTime: Long, toTime: Long) throws -> Promise? {
        let nativePromise = try native.getTimeSeriesPromise(type: type,
                                                            symbol: symbol,
                                                            fromTime: fromTime,
                                                            toTime: toTime)
        return Promise(native: nativePromise)

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
