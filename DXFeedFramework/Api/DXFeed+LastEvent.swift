//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation

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
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    @available(iOS 13.0, *)
    @available(macOS 10.15, *)
    func getLastEvent(type: IEventType.Type,
                      symbol: Symbol) -> Task<MarketEvent?, Error> {
        let task = Task {
            let defaultValue: MarketEvent? = nil
            if Task.isCancelled {
                return defaultValue
            }

            let promise = try getLastEventPromise(type: type, symbol: symbol)
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
    func getLastEventPromise(type: IEventType.Type, symbol: Symbol) throws -> Promise {
        let nativePromise = try nativeFeed.getLastEventPromise(type: type, symbol: symbol)
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
    /// - Returns: The list of Task
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    @available(iOS 13.0, *)
    @available(macOS 10.15, *)
    func getLastEventsTasks(type: IEventType.Type, symbols: [Symbol]) throws -> [Task<MarketEvent?, Error>]? {
        let promises = try getLastEventPromises(type: type, symbols: symbols)
        let tasks = promises?.compactMap { promise in
            let task = Task {
                let defaultValue: MarketEvent? = nil
                if Task.isCancelled {
                    return defaultValue
                }

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
        return tasks
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
    /// - Returns: The list of ``MarketEvent``
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    @available(iOS 13.0, *)
    @available(macOS 10.15, *)
    func getLastEvents(type: IEventType.Type, symbols: [Symbol]) async throws -> [MarketEvent] {
        let tasks = try getLastEventsTasks(type: type, symbols: symbols)
        return await withTaskGroup(of: MarketEvent?.self, returning: [MarketEvent].self) { taskGroup in
            tasks?.forEach { task in
                taskGroup.addTask {
                    let result = await task.result
                    switch result {
                    case .success(let value):
                        return value
                    case .failure:
                        return nil
                    }
                }
            }
            var events = [MarketEvent]()
            for await result in taskGroup {
                if let result = result {
                    events.append(result)
                }
            }
            return events
        }
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
        let nativePromises = try nativeFeed.getLastEventPromises(type: type, symbols: symbols)
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
            let nativePromise = try nativeFeed.getIndexedEventsPromise(type: type,
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
        let nativePromise = try nativeFeed.getIndexedEventsPromise(type: type, symbol: symbol, source: source)
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
            let nativePromise = try nativeFeed.getTimeSeriesPromise(type: type,
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
        let nativePromise = try nativeFeed.getTimeSeriesPromise(type: type,
                                                            symbol: symbol,
                                                            fromTime: fromTime,
                                                            toTime: toTime)
        return Promise(native: nativePromise)

    }
}
