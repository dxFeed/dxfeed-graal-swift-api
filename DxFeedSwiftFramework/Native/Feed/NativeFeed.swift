//
//  NativeFeed.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 22.05.23.
//

import Foundation
@_implementationOnly import graal_api

class NativeFeed {
    let feed: UnsafeMutablePointer<dxfg_feed_t>?
#warning("TODO: implement it")
    deinit {
        if let feed = feed {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_JavaObjectHandler_release(thread, &(feed.pointee.handler)))
        }
    }
    init(feed: UnsafeMutablePointer<dxfg_feed_t>) {
        self.feed = feed
    }
}
