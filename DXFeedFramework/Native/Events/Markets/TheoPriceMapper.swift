//
//  TheoPriceMapper.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 06.10.23.
//

import Foundation
@_implementationOnly import graal_api

class TheoPriceMapper: Mapper {
    let type = dxfg_theo_price_t.self

    func fromNative(native: UnsafeMutablePointer<dxfg_event_type_t>) -> MarketEvent? {
        let event = native.withMemoryRebound(to: type, capacity: 1) { native in
            return TheoPrice(native: native.pointee)
        }
        return event
    }

    func toNative(event: MarketEvent) -> UnsafeMutablePointer<dxfg_event_type_t>? {
        let pointer = UnsafeMutablePointer<dxfg_theo_price_t>.allocate(capacity: 1)
        pointer.pointee.market_event.event_symbol = event.eventSymbol.toCStringRef()
        pointer.pointee.market_event.event_time = event.eventTime

        let theoPrice = event.theoPrice

        pointer.pointee.event_flags = theoPrice.eventFlags
        pointer.pointee.index = theoPrice.index
        pointer.pointee.price = theoPrice.price
        pointer.pointee.underlying_price = theoPrice.underlyingPrice
        pointer.pointee.delta = theoPrice.delta
        pointer.pointee.gamma = theoPrice.gamma
        pointer.pointee.dividend = theoPrice.dividend
        pointer.pointee.interest = theoPrice.interest

        let eventType = pointer.withMemoryRebound(to: dxfg_event_type_t.self, capacity: 1) { pointer in
            pointer.pointee.clazz = DXFG_EVENT_THEO_PRICE
            return pointer
        }
        return eventType
    }
}
