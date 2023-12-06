//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
@_implementationOnly import graal_api

extension Quote {
    convenience init(native: dxfg_quote_t) {
        self.init(String(pointee: native.market_event.event_symbol))

        self.eventTime = native.market_event.event_time
        self.timeMillisSequence = native.time_millis_sequence
        self.timeNanoPart = native.time_nano_part
        self.bidTime = native.bid_time
        self.bidExchangeCode = native.bid_exchange_code
        self.bidPrice = native.bid_price
        self.bidSize = native.bid_size
        self.askTime = native.ask_time
        self.askExchangeCode = native.ask_exchange_code
        self.askPrice = native.ask_price
        self.askSize = native.ask_size
    }

}
