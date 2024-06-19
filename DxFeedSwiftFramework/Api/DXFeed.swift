//
//  DXFeed.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 22.05.23.
//

import Foundation

class DXFeed {
    private let native: NativeFeed
    private var attachedSubscriptions = ConcurrentSet<DXFeedSubcription>()

    deinit {
    }

    internal init(native: NativeFeed?) throws {
        if let native = native {
            self.native = native
        } else {
            throw NativeException.nilValue
        }
    }

    public func createSubscription(_ events: [EventCode]) throws -> DXFeedSubcription {
        return try DXFeedSubcription(native: native.createSubscription(events), events: events)
    }

    public func createSubscription(_ event: EventCode) throws -> DXFeedSubcription {
        return try DXFeedSubcription(native: native.createSubscription(event), events: [event])
    }
}
