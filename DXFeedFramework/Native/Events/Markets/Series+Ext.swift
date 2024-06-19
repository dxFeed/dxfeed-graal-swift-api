//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
@_implementationOnly import graal_api

extension Series {
    convenience init(native: dxfg_series_t) {
        self.init(String(pointee: native.market_event.event_symbol))

        self.eventTime = native.market_event.event_time
        self.eventFlags = native.event_flags
        self.index = native.index
        self.timeSequence = native.time_sequence
        self.expiration = native.expiration
        self.volatility = native.volatility
        self.callVolume = native.call_volume
        self.putVolume = native.put_volume
        self.putCallRatio = native.put_call_ratio
        self.forwardPrice = native.forward_price
        self.dividend = native.dividend
        self.interest = native.interest
    }
}
