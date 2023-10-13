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
        var pointee = pointer.pointee
        pointee.market_event.event_symbol = event.eventSymbol.toCStringRef()
        pointee.market_event.event_time = event.eventTime

        let series = event.series

        pointee.index = series.index
        pointee.event_flags = series.eventFlags
        pointee.time_sequence = series.timeSequence
        pointee.expiration = series.expiration
        pointee.volatility = series.volatility
        pointee.call_volume = series.callVolume
        pointee.put_volume = series.putVolume
        pointee.put_call_ratio = series.putCallRatio
        pointee.forward_price = series.forwardPrice
        pointee.dividend = series.dividend
        pointee.interest = series.interest

        let eventType = pointer.withMemoryRebound(to: dxfg_event_type_t.self, capacity: 1) { pointer in
            pointer.pointee.clazz = DXFG_EVENT_SERIES
            return pointer
        }
        return eventType
    }
}
