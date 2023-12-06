//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
@_implementationOnly import graal_api

class TradeMapper: Mapper {
    let type = dxfg_trade_t.self

    func fromNative(native: UnsafeMutablePointer<dxfg_event_type_t>) -> MarketEvent? {
        let event = native.withMemoryRebound(to: type, capacity: 1) { native in
            return Trade(native: native.pointee.trade_base)
        }
        return event
    }

    func toNative(event: MarketEvent) -> UnsafeMutablePointer<dxfg_event_type_t>? {
        let pointer = UnsafeMutablePointer<dxfg_trade_base_t>.allocate(capacity: 1)
        pointer.pointee.market_event.event_symbol = event.eventSymbol.toCStringRef()
        pointer.pointee.market_event.event_time = event.eventTime

        let trade = event.trade
        pointer.pointee.time_sequence = trade.timeSequence
        pointer.pointee.time_nano_part = trade.timeNanoPart
        pointer.pointee.exchange_code = trade.exchangeCode
        pointer.pointee.price = trade.price
        pointer.pointee.change = trade.change
        pointer.pointee.size = trade.size
        pointer.pointee.day_id = trade.dayId
        pointer.pointee.day_volume = trade.dayVolume
        pointer.pointee.day_turnover = trade.dayTurnover
        pointer.pointee.flags = trade.flags

        let eventType = pointer.withMemoryRebound(to: dxfg_event_type_t.self, capacity: 1) { pointer in
            pointer.pointee.clazz = DXFG_EVENT_TRADE
            return pointer
        }
        return eventType
    }
}
