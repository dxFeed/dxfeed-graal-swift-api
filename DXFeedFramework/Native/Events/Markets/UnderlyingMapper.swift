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
        pointer.pointee.market_event.event_symbol = event.eventSymbol.toCStringRef()
        pointer.pointee.market_event.event_time = event.eventTime

        let underlying = event.underlying

        pointer.pointee.event_flags = underlying.eventFlags
        pointer.pointee.index = underlying.index
        pointer.pointee.volatility = underlying.volatility
        pointer.pointee.front_volatility = underlying.frontVolatility
        pointer.pointee.back_volatility = underlying.backVolatility
        pointer.pointee.call_volume = underlying.callVolume
        pointer.pointee.put_volume = underlying.putVolume
        pointer.pointee.put_call_ratio = underlying.putCallRatio

        let eventType = pointer.withMemoryRebound(to: dxfg_event_type_t.self, capacity: 1) { pointer in
            pointer.pointee.clazz = DXFG_EVENT_UNDERLYING
            return pointer
        }
        return eventType
    }
}
