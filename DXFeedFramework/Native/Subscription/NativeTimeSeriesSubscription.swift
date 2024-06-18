//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation
@_implementationOnly import graal_api

/// Native wrapper over the Java com.dxfeed.api.DXFeedTimeSeriesSubscription class.
/// The location of the imported functions is in the header files "dxfg_subscription.h".
class NativeTimeSeriesSubscription {
    let native: UnsafeMutablePointer<dxfg_time_series_subscription_t>?
    let subscription: NativeSubscription

    deinit {
    }

    init(native: UnsafeMutablePointer<dxfg_time_series_subscription_t>?) {
        self.native = native
        let pointer = UnsafeMutablePointer<dxfg_subscription_t>.allocate(capacity: 1)
        pointer.pointee = self.native!.pointee.sub
        self.subscription = NativeSubscription(subscription: pointer)
    }

    func set(fromTime: Long) throws {
        let thread = currentThread()
        _ = try ErrorCheck.nativeCall(thread, dxfg_DXFeedTimeSeriesSubscription_setFromTime(
            thread,
            native,
            fromTime))
    }

}
