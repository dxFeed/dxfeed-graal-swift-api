//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation

public class DXFeedTimeSeriesSubscription: DXFeedSubcription {
    /// Subscription native wrapper.
    private let native: NativeTimeSeriesSubscription?

    internal init(native: NativeTimeSeriesSubscription?, events: [EventCode]) throws {
        if let native = native {
            self.native = native
        } else {
            throw ArgumentException.argumentNil
        }
        try super.init(native: native?.subscription, events: events)
    }

    func set(fromTime: Long) throws {
        try native?.set(fromTime: fromTime)
    }
}
