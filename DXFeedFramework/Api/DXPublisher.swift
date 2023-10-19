//
//  DXPublisher.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 23.05.23.
//

import Foundation

/// Provides API for publishing of events to local or remote  ``DXFeed``
/// 
/// [Read it first Javadoc](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXPublisher.html)
public class DXPublisher {
    /// Feed native wrapper.
    private let native: NativePublisher

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
    /// - Throws: GraalException. Rethrows exception from Java.recore
    public func publish(events: [MarketEvent]) throws {
        try native.publishEvents(events: events)
    }
}
