//
//  TradeMapper.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 07.06.23.
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
        var pointee = pointer.pointee
        pointee.market_event.event_symbol = event.eventSymbol.toCStringRef()
        pointee.market_event.event_time = event.eventTime

        let trade = event.trade
        pointee.time_sequence = trade.timeSequence
        pointee.time_nano_part = trade.timeNanoPart
        pointee.exchange_code = trade.exchangeCode
        pointee.price = trade.price
        pointee.change = trade.change
        pointee.size = trade.size
        pointee.day_id = trade.dayId
        pointee.day_volume = trade.dayVolume
        pointee.day_turnover = trade.dayTurnover
        pointee.flags = trade.flags

        let eventType = pointer.withMemoryRebound(to: dxfg_event_type_t.self, capacity: 1) { pointer in
            pointer.pointee.clazz = DXFG_EVENT_TRADE
            return pointer
        }
        return eventType
    }
}
