//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation
@_implementationOnly import graal_api

class OtcMarketsOrderMapper: Mapper {
    let type = dxfg_otc_markets_order_t.self

    func fromNative(native: UnsafeMutablePointer<dxfg_event_type_t>) -> MarketEvent? {
        let event = native.withMemoryRebound(to: type, capacity: 1) { native in
            print("ASD")
            let native123 = native.pointee
            return OtcMarketsOrder(otcNative: native.pointee)
        }
        return event
    }

    func toNative(event: MarketEvent) -> UnsafeMutablePointer<dxfg_event_type_t>? {
        let pointer = UnsafeMutablePointer<TypeAlias>.allocate(capacity: 1)
        pointer.pointee.order_base.order_base.market_event.event_symbol = event.eventSymbol.toCStringRef()
        pointer.pointee.order_base.order_base.market_event.event_time = event.eventTime

        let order = event.otcMarketsOrder

        pointer.pointee.order_base.order_base.market_event.event_time = order.eventTime
        pointer.pointee.order_base.order_base.event_flags = order.eventFlags
        pointer.pointee.order_base.order_base.index = order.index
        pointer.pointee.order_base.order_base.time_sequence = order.timeSequence
        pointer.pointee.order_base.order_base.time_nano_part = order.timeNanoPart
        pointer.pointee.order_base.order_base.action_time = order.actionTime
        pointer.pointee.order_base.order_base.order_id = order.orderId
        pointer.pointee.order_base.order_base.aux_order_id = order.auxOrderId
        pointer.pointee.order_base.order_base.price = order.price
        pointer.pointee.order_base.order_base.size = order.size
        pointer.pointee.order_base.order_base.executed_size = order.executedSize
        pointer.pointee.order_base.order_base.count = order.count
        pointer.pointee.order_base.order_base.flags = order.flags
        pointer.pointee.order_base.order_base.trade_id = order.tradeId
        pointer.pointee.order_base.order_base.trade_price = order.tradePrice
        pointer.pointee.order_base.order_base.trade_size = order.tradeSize

        pointer.pointee.order_base.market_maker = order.marketMaker?.toCStringRef()
        pointer.pointee.quote_access_payment = order.quoteAccessPayment
        pointer.pointee.otc_markets_flags = order.otcMarketsFlags

        let eventType = pointer.withMemoryRebound(to: dxfg_event_type_t.self, capacity: 1) { pointer in
            pointer.pointee.clazz = DXFG_EVENT_OTC_MARKETS_ORDER
            return pointer
        }
        return eventType
    }
}
