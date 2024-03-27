//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation
@_implementationOnly import graal_api

extension OtcMarketsOrder {
    convenience init(otcNative: dxfg_otc_markets_order_t) {
        self.init(String(pointee: otcNative.order_base.order_base.market_event.event_symbol))

        self.eventTime = otcNative.order_base.order_base.market_event.event_time
        self.eventFlags = otcNative.order_base.order_base.event_flags
        try? self.setIndex(otcNative.order_base.order_base.index)
        self.timeSequence = otcNative.order_base.order_base.time_sequence
        self.timeNanoPart = otcNative.order_base.order_base.time_nano_part
        self.actionTime = otcNative.order_base.order_base.action_time
        self.orderId = otcNative.order_base.order_base.order_id
        self.auxOrderId = otcNative.order_base.order_base.aux_order_id
        self.price = otcNative.order_base.order_base.price
        self.size = otcNative.order_base.order_base.size
        self.executedSize = otcNative.order_base.order_base.executed_size
        self.count = otcNative.order_base.order_base.count
        self.flags = otcNative.order_base.order_base.flags
        self.tradeId = otcNative.order_base.order_base.trade_id
        self.tradePrice = otcNative.order_base.order_base.trade_price
        self.tradeSize = otcNative.order_base.order_base.trade_size

        self.marketMaker = String(nullable: otcNative.order_base.market_maker)
        self.quoteAccessPayment = otcNative.quote_access_payment
        self.otcMarketsFlags = otcNative.otc_markets_flags
    }
}
