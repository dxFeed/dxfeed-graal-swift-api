//
//  UnderlyingMapper.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 06.10.23.
//

import Foundation
@_implementationOnly import graal_api

class UnderlyingMapper: Mapper {
    let type = dxfg_underlying_t.self

    func fromNative(native: UnsafeMutablePointer<dxfg_event_type_t>) -> MarketEvent? {
        let event = native.withMemoryRebound(to: type, capacity: 1) { native in
            return Underlying(native: native.pointee)
        }
        return event
    }

    func toNative(event: MarketEvent) -> UnsafeMutablePointer<dxfg_event_type_t>? {
        let pointer = UnsafeMutablePointer<dxfg_underlying_t>.allocate(capacity: 1)
        var pointee = pointer.pointee
        pointee.market_event.event_symbol = event.eventSymbol.toCStringRef()
        pointee.market_event.event_time = event.eventTime

        let underlying = event.underlying

        pointee.event_flags = underlying.eventFlags
        pointee.index = underlying.index
        pointee.volatility = underlying.volatility
        pointee.front_volatility = underlying.frontVolatility
        pointee.back_volatility = underlying.backVolatility
        pointee.call_volume = underlying.callVolume
        pointee.put_volume = underlying.putVolume
        pointee.put_call_ratio = underlying.putCallRatio

        let eventType = pointer.withMemoryRebound(to: dxfg_event_type_t.self, capacity: 1) { pointer in
            pointer.pointee.clazz = DXFG_EVENT_TRADE
            return pointer
        }
        return eventType
    }
}
