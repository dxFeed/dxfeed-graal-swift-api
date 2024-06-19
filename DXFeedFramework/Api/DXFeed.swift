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
    ///     - events: The list of event codes.
    /// - Returns: ``DXFeedSubcription``
    /// - Throws: ``GraalException``. Rethrows exception from Java., ``ArgumentException/argumentNil``
    public func createSubscription(_ events: [EventCode]) throws -> DXFeedSubcription {
        return try DXFeedSubcription(native: native.createSubscription(events), events: events)
    }
    /// Creates new subscription for a one event type that is attached to this feed.
    ///
    /// [Javadoc](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXFeed.html#createSubscription-java.lang.Class)
    /// - Parameters:
    ///     - event: event code
    /// - Returns: ``DXFeedSubcription``
    /// - Throws: GraalException. Rethrows exception from Java.
    public func createSubscription(_ event: EventCode) throws -> DXFeedSubcription {
        return try DXFeedSubcription(native: native.createSubscription(event), events: [event])
    }

    public func createTimeSeriesSubscription(_ event: EventCode) throws -> DXFeedTimeSeriesSubscription {
        return try DXFeedTimeSeriesSubscription(native: native.createTimeSeriesSubscription(event), events: [event])

    }
}
