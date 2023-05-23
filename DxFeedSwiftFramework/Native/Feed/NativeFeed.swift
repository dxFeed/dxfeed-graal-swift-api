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
    init(feed: UnsafeMutablePointer<dxfg_feed_t>) {
        self.feed = feed
    }
}
