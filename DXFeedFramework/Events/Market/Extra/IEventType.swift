//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

/// Marks all event types that can be received via dxFeed API.
///
/// Events are considered instantaneous, non-persistent, and unconflateable
/// (each event is individually delivered) unless they implement one of interfaces
/// defined in this package to further refine their meaning.
///
/// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/EventType.html)
public protocol IEventType {
    /// Gets or sets event symbol that identifies this event type ``DXFeedSubscription``.
    ///
    /// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/EventType.html#getEventSymbol--)
    var eventSymbol: String { get set }
    /// Gets or sets time when event was created or zero when time is not available.
    ///
    /// The difference, measured in milliseconds, between the event creation time and midnight,
    /// January 1, 1970 UTC or zero when time is not available.
    ///
    /// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/EventType.html#getEventTime--)
    var eventTime: Int64 { get set }

    ///  Hashcode fot perftest and other purposes.
    var hashCode: Int { get }

    static var type: EventCode { get }
}
