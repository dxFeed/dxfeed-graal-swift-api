//
//  GreeksMapper.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 06.10.23.
//

import Foundation
@_implementationOnly import graal_api

class GreeksMapper: Mapper {
    let type = dxfg_greeks_t.self

    func fromNative(native: UnsafeMutablePointer<dxfg_event_type_t>) -> MarketEvent? {
        let event = native.withMemoryRebound(to: type, capacity: 1) { native in
            return Greeks(native: native.pointee)
        }
        return event
    }

    func toNative(event: MarketEvent) -> UnsafeMutablePointer<dxfg_event_type_t>? {
        let pointer = UnsafeMutablePointer<dxfg_greeks_t>.allocate(capacity: 1)
        var pointee = pointer.pointee
        pointee.market_event.event_symbol = event.eventSymbol.toCStringRef()
        pointee.market_event.event_time = event.eventTime

        let greeks = event.greeks
        pointee.event_flags = greeks.eventFlags
        pointee.index = greeks.index
        pointee.price = greeks.price
        pointee.volatility = greeks.volatility
        pointee.delta = greeks.delta
        pointee.gamma = greeks.gamma
        pointee.theta = greeks.theta
        pointee.rho = greeks.rho
        pointee.vega = greeks.vega

        let eventType = pointer.withMemoryRebound(to: dxfg_event_type_t.self, capacity: 1) { pointer in
            pointer.pointee.clazz = DXFG_EVENT_GREEKS
            return pointer
        }
        return eventType
    }
}
