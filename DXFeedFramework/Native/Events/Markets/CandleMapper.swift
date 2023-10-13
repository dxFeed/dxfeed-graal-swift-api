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
        var pointee = pointer.pointee
        pointee.event_symbol = event.eventSymbol.toCStringRef()
        pointee.event_time = event.eventTime

        let candle = event.candle
        pointee.event_flags = candle.eventFlags
        pointee.index = candle.index
        pointee.count = candle.count
        pointee.open = candle.open
        pointee.high = candle.high
        pointee.low = candle.low
        pointee.close = candle.close
        pointee.volume = candle.volume
        pointee.vwap = candle.vwap
        pointee.bid_volume = candle.bidVolume
        pointee.ask_volume = candle.askVolume
        pointee.imp_volatility = candle.impVolatility
        pointee.open_interest = candle.openInterest

        let eventType = pointer.withMemoryRebound(to: dxfg_event_type_t.self, capacity: 1) { pointer in
            pointer.pointee.clazz = DXFG_EVENT_CANDLE
            return pointer
        }
        return eventType
    }
}
