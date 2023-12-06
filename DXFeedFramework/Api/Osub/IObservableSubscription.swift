//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
