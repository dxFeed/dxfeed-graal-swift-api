//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

/// Provides API for publishing of events to local or remote  ``DXFeed``
/// 
/// [Read it first Javadoc](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXPublisher.html)
public class DXPublisher {
    /// Feed native wrapper.
    private let native: NativePublisher
    private let subscriptionsByClass = ConcurrentDict<EventCode, DXObservableSubscription>()

    deinit {
    }

    internal init(native: NativePublisher?) throws {
        if let native = native {
            self.native = native
        } else {
            throw ArgumentException.argumentNil
        }
    }

    /// Publishes events to the corresponding feed.
    ///
    /// If the ``DXEndpoint`` of this publisher has
    /// ``DXEndpoint/Role-swift.enum/publisher`` role and it is connected, the
    /// published events will be delivered to the remote endpoints. Local ``DXEndpoint/getFeed()`` will
    /// always receive published events.
    /// [Read it first Javadoc](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXPublisher.html#publishEvents-java.util.Collection-)
    /// - Parameters:
    ///   - events: The collection of events to publish.
    /// - Throws: GraalException. Rethrows exception from Java.
    public func publish(events: [MarketEvent]) throws {
        try native.publishEvents(events: events)
    }

    /// Returns observable set of subscribed symbols for the specified event type.
    /// Note, that subscription is represented by object symbols.
    ///
    ///  The set of subscribed symbols contains ``WildcardSymbol/all`` if and
    /// only if there is a subscription to this wildcard symbol.
    ///  If ``DXFeedTimeSeriesSubscription`` is used
    /// to subscribe to time-service of the events of this type, then instances of
    /// ``TimeSeriesSubscriptionSymbol`` class represent the corresponding subscription item.
    ///  The resulting observable subscription can generate repeated
    /// ``ObservableSubscriptionChangeListener/symbolsAdded(symbols:)`` notifications to
    /// its listeners for the same symbols without the corresponding
    /// ``ObservableSubscriptionChangeListener/symbolsRemoved(symbols:)``
    /// notifications in between them. It happens when subscription disappears, cached data is lost, and subscription
    /// reappears again. On each ``ObservableSubscriptionChangeListener/symbolsAdded(symbols:)``
    /// notification data provider shall ``publish(events:)`` the most recent events for
    /// the corresponding symbols.
    /// - Parameters:
    ///    - event: eventType the class of event.
    /// - Returns: Observable subscription for the specified event type.
    /// - Throws: GraalException. Rethrows exception from Java.
    public func getSubscription(_ event: IEventType.Type) throws -> IObservableSubscription {
        if let subscription = subscriptionsByClass[event.type] {
            return subscription
        } else {
            let subscription = try DXObservableSubscription(native: native.createSubscription(event), events: [event])
            subscriptionsByClass[event.type] = subscription
            return subscription
        }
    }
}
