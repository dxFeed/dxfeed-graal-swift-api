//
//  NativeFeed.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 22.05.23.
//

import Foundation
@_implementationOnly import graal_api

/// Native wrapper over the Java com.dxfeed.api.DXFeed class.
/// The location of the imported functions is in the header files "dxfg_feed.h".
class NativeFeed {
    let feed: UnsafeMutablePointer<dxfg_feed_t>?
    deinit {
        if let feed = feed {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_JavaObjectHandler_release(thread, &(feed.pointee.handler)))
        }
    }
    init(feed: UnsafeMutablePointer<dxfg_feed_t>) {
        self.feed = feed
    }

    func createSubscription(_ events: [EventCode]) throws -> NativeSubscription? {
        let nativeCodes = events.map { $0.nativeCode() }
        let elements = ListNative(elements: nativeCodes)
        let listPointer = elements.newList()
        defer {
            listPointer.deinitialize(count: 1)
            listPointer.deallocate()
        }

        let thread = currentThread()
        let subscription = try ErrorCheck.nativeCall(thread,
                                                     dxfg_DXFeed_createSubscription2(thread,
                                                                                     self.feed,
                                                                                     listPointer))
        return NativeSubscription(subscription: subscription)
    }

    func createSubscription(_ event: EventCode) throws -> NativeSubscription? {
        let thread = currentThread()
        let subscription = try ErrorCheck.nativeCall(thread,
                                                     dxfg_DXFeed_createSubscription(thread,
                                                                                    self.feed,
                                                                                    event.nativeCode()))
        return NativeSubscription(subscription: subscription)
    }
}
