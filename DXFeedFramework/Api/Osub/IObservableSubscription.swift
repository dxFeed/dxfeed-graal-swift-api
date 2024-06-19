//
//  IObservableSubscription.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 18.08.23.
//

import Foundation

/// Observable set of subscription symbols for the specific event type.
///
/// [Javadoc](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/osub/ObservableSubscription.html)
public protocol IObservableSubscription {
    /// Gets a value indicating whether if this subscription is closed.
    ///
    /// [Javadoc](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/osub/ObservableSubscription.html#isClosed--)
    func isClosed() -> Bool
    /// Gets a set of subscribed event types. The resulting set cannot be modified.
    ///
    /// [Javadoc](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/osub/ObservableSubscription.html#getEventTypes--)
    /// - Returns: a set of subscribed event types.
    var eventTypes: Set<EventCode> { get }
    /// Gets a value indicating whether if this subscription contains the corresponding event type.
    ///
    /// [Javadoc](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/osub/ObservableSubscription.html#containsEventType-java.lang.Class-)
    /// - Parameters:
    ///   - eventType: The event type.
    /// - Returns: **true** if this subscription contains the corresponding event type
    func isContains(_ eventType: EventCode) -> Bool
}
