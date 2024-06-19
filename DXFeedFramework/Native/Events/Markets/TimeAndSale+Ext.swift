//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
@_implementationOnly import graal_api

extension TimeAndSale {
    convenience init(native: dxfg_time_and_sale_t) {
        self.init(String(pointee: native.market_event.event_symbol))
        self.eventTime = native.market_event.event_time
        self.eventFlags = native.event_flags
        self.index = native.index
        self.timeNanoPart = native.time_nano_part
        self.exchangeCode = native.exchange_code
        self.price = native.price
        self.size = native.size
        self.bidPrice = native.bid_price
        self.askPrice = native.ask_price
        self.exchangeSaleConditions = String(pointee: native.exchange_sale_conditions)
        self.flags = native.flags
        self.buyer = String(nullable: native.buyer)
        self.seller = String(nullable: native.seller)
    }
}
