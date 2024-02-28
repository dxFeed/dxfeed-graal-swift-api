//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

/// Main entry class for dxFeed API.
///
/// [Read it first Javadoc](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXFeed.html)
public class DXFeed {
    /// Feed native wrapper.
    private let native: NativeFeed

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
    func getLastEvent(type: MarketEvent) throws -> ILastingEvent? {
        return try native.getLastEvent(type: type)
    }

    func getLastEvents(types: [MarketEvent]) throws -> [ILastingEvent] {
        return try native.getLastEvents(types: types)
    }
}

public extension DXFeed {
    func getLastEventPromise(type: IEventType.Type, symbol: Symbol) throws -> Promise? {
        let nativePromise = try native.getLastEventPromise(type: type, symbol: symbol)
        return Promise(native: nativePromise)
    }

    func getLastEventPromises(type: IEventType.Type, symbols: [Symbol]) throws -> [Promise]? {
        let nativePromises = try native.getLastEventPromises(type: type, symbols: symbols)
        return nativePromises?.map({ promise in
            Promise(native: promise)
        })
    }

    func getIndexedEventsPromise(type: IEventType.Type, symbol: Symbol, source: IndexedEventSource) throws -> Promise? {
        let nativePromise = try native.getIndexedEventsPromise(type: type, symbol: symbol, source: source)
        return Promise(native: nativePromise)
    }


    @available(macOS 10.15, *)
    func getTimeSeries(type: IEventType.Type, symbol: Symbol, fromTime: Long, toTime: Long) -> Task<[MarketEvent]?, Error> {
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

    func getTimeSeriesPromise(type: IEventType.Type, symbol: Symbol, fromTime: Long, toTime: Long) throws -> Promise? {
        let nativePromise = try native.getTimeSeriesPromise(type: type,
                                                            symbol: symbol,
                                                            fromTime: fromTime,
                                                            toTime: toTime)
        return Promise(native: nativePromise)

    }
}
