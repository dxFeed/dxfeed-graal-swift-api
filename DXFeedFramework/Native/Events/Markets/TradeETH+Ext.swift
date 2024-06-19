//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
@_implementationOnly import graal_api

extension TradeETH {
    convenience init(native: dxfg_trade_base_t) {
        self.init(String(pointee: native.market_event.event_symbol))

        self.eventTime = native.market_event.event_time
        self.timeSequence = native.time_sequence
        self.timeNanoPart = native.time_nano_part
        self.exchangeCode = native.exchange_code
        self.price = native.price
        self.change = native.change
        self.size = native.size
        self.dayId = native.day_id
        self.dayVolume = native.day_volume
        self.dayTurnover = native.day_turnover
        self.flags = native.flags
    }
}
