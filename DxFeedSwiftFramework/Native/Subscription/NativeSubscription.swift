//
//  NativeSubscription.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 30.05.23.
//

import Foundation
@_implementationOnly import graal_api

class NativeSubscription {
    let subscription: UnsafeMutablePointer<dxfg_subscription_t>?
    deinit {
        if let subscription = subscription {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread,
                                           dxfg_JavaObjectHandler_release(thread, &(subscription.pointee.handler)))
        }
    }
    init(subscription: UnsafeMutablePointer<dxfg_subscription_t>?) {
        self.subscription = subscription
    }
}
