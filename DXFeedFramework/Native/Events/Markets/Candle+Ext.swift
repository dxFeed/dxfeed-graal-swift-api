//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
@_implementationOnly import graal_api

extension Candle {
    convenience init(native: dxfg_candle_t) {
        self.init(type: .candle)
        self.eventSymbol = String(pointee: native.event_symbol)
        self.eventTime = native.event_time
        self.eventFlags = native.event_flags
        self.index = native.index
        self.count = native.count
        self.open = native.open
        self.high = native.high
        self.low = native.low
        self.close = native.close
        self.volume = native.volume
        self.vwap = native.vwap
        self.bidVolume = native.bid_volume
        self.askVolume = native.ask_volume
        self.impVolatility = native.imp_volatility
        self.openInterest = native.open_interest
    }
}
