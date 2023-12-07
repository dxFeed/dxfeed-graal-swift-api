//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
@_implementationOnly import graal_api

extension Order {
    convenience init(native: dxfg_order_t) {
        self.init(String(pointee: native.order_base.market_event.event_symbol))

        self.eventTime = native.order_base.market_event.event_time
        self.eventFlags = native.order_base.event_flags
        try? self.setIndex(native.order_base.index)
        self.timeSequence = native.order_base.time_sequence
        self.timeNanoPart = native.order_base.time_nano_part
        self.actionTime = native.order_base.action_time
        self.orderId = native.order_base.order_id
        self.auxOrderId = native.order_base.aux_order_id
        self.price = native.order_base.price
        self.size = native.order_base.size
        self.executedSize = native.order_base.executed_size
        self.count = native.order_base.count
        self.flags = native.order_base.flags
        self.tradeId = native.order_base.trade_id
        self.tradePrice = native.order_base.trade_price
        self.tradeSize = native.order_base.trade_size

        self.marketMaker = String(nullable: native.market_maker)
    }
}
