//
//  DXFeed.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 22.05.23.
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
            throw NativeException.nilValue
        }
    }
    /// Creates new subscription for a list of event types that is attached to this feed.
    ///
    /// [Javadoc](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXFeed.html#createSubscription-java.lang.Class)
    /// - Parameters:
    ///     - events: The list of event codes.
    /// - Returns: ``DXFeedSubcription``
    /// - Throws: ``GraalException``. Rethrows exception from Java., ``NativeException/nilValue``
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
}
