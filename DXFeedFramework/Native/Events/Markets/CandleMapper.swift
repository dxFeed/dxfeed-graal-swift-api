//
//  CandleMapper.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 13.07.23.
//

@_implementationOnly import graal_api

class CandleMapper: Mapper {
    var type = dxfg_candle_t.self

    func fromNative(native: UnsafeMutablePointer<dxfg_event_type_t>) -> MarketEvent? {
        let event = native.withMemoryRebound(to: type, capacity: 1) { native in
            return Candle(native: native.pointee)
        }
        return event
    }

    func toNative(event: MarketEvent) -> UnsafeMutablePointer<dxfg_event_type_t>? {
        let pointer = UnsafeMutablePointer<dxfg_candle_t>.allocate(capacity: 1)
        pointer.pointee.event_symbol = event.eventSymbol.toCStringRef()
        pointer.pointee.event_time = event.eventTime

        let candle = event.candle
        pointer.pointee.event_flags = candle.eventFlags
        pointer.pointee.index = candle.index
        pointer.pointee.count = candle.count
        pointer.pointee.open = candle.open
        pointer.pointee.high = candle.high
        pointer.pointee.low = candle.low
        pointer.pointee.close = candle.close
        pointer.pointee.volume = candle.volume
        pointer.pointee.vwap = candle.vwap
        pointer.pointee.bid_volume = candle.bidVolume
        pointer.pointee.ask_volume = candle.askVolume
        pointer.pointee.imp_volatility = candle.impVolatility
        pointer.pointee.open_interest = candle.openInterest

        let eventType = pointer.withMemoryRebound(to: dxfg_event_type_t.self, capacity: 1) { pointer in
            pointer.pointee.clazz = DXFG_EVENT_CANDLE
            return pointer
        }
        return eventType
    }
}
