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
    var native: UnsafeMutablePointer<dxfg_time_series_subscription_t>?

    deinit {
        if let native = native {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread,
                                           dxfg_JavaObjectHandler_release(thread,
                                                                          &(native.pointee.sub.handler)))
        }
    }

    init(native: UnsafeMutablePointer<dxfg_time_series_subscription_t>?) {
        self.native = native
        var subscription = self.native?.pointee.sub
    }

    lazy var subscription: NativeSubscription? = {
        if var subscr = native?.pointee.sub {
            return NativeSubscription(subscription: &subscr)
        } else {
            return nil
        }
    }()

}
