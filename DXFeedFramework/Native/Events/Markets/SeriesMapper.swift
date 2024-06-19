//
//  SeriesMapper.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 12.10.23.
//

import Foundation
@_implementationOnly import graal_api

class SeriesMapper: Mapper {
    let type = dxfg_series_t.self

    func fromNative(native: UnsafeMutablePointer<dxfg_event_type_t>) -> MarketEvent? {
        let event = native.withMemoryRebound(to: type, capacity: 1) { native in
            return Series(native: native.pointee)
        }
        return event
    }

    func toNative(event: MarketEvent) -> UnsafeMutablePointer<dxfg_event_type_t>? {
        let pointer = UnsafeMutablePointer<TypeAlias>.allocate(capacity: 1)
        pointer.pointee.market_event.event_symbol = event.eventSymbol.toCStringRef()
        pointer.pointee.market_event.event_time = event.eventTime

        let series = event.series

        pointer.pointee.index = series.index
        pointer.pointee.event_flags = series.eventFlags
        pointer.pointee.time_sequence = series.timeSequence
        pointer.pointee.expiration = series.expiration
        pointer.pointee.volatility = series.volatility
        pointer.pointee.call_volume = series.callVolume
        pointer.pointee.put_volume = series.putVolume
        pointer.pointee.put_call_ratio = series.putCallRatio
        pointer.pointee.forward_price = series.forwardPrice
        pointer.pointee.dividend = series.dividend
        pointer.pointee.interest = series.interest

        let eventType = pointer.withMemoryRebound(to: dxfg_event_type_t.self, capacity: 1) { pointer in
            pointer.pointee.clazz = DXFG_EVENT_SERIES
            return pointer
        }
        return eventType
    }
}
