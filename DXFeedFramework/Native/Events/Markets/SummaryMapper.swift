//
//  SummaryMapper.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 06.10.23.
//

import Foundation
@_implementationOnly import graal_api

class SummaryMapper: Mapper {
    var type = dxfg_summary_t.self

    func fromNative(native: UnsafeMutablePointer<dxfg_event_type_t>) -> MarketEvent? {
        let event = native.withMemoryRebound(to: type, capacity: 1) { native in
            return Summary(native: native.pointee)
        }
        return event
    }

    func toNative(event: MarketEvent) -> UnsafeMutablePointer<dxfg_event_type_t>? {
        let pointer = UnsafeMutablePointer<dxfg_summary_t>.allocate(capacity: 1)
        var pointee = pointer.pointee
        pointee.market_event.event_symbol = event.eventSymbol.toCStringRef()
        pointee.market_event.event_time = event.eventTime

        let summary = event.summary
        pointee.day_id = summary.dayId
        pointee.day_open_price = summary.dayOpenPrice
        pointee.day_high_price = summary.dayHighPrice
        pointee.day_low_price = summary.dayLowPrice
        pointee.day_close_price = summary.dayClosePrice
        pointee.prev_day_id = summary.prevDayId
        pointee.prev_day_close_price = summary.prevDayClosePrice
        pointee.prev_day_volume = summary.prevDayVolume
        pointee.open_interest = summary.openInterest
        pointee.flags = summary.flags

        let eventType = pointer.withMemoryRebound(to: dxfg_event_type_t.self, capacity: 1) { pointer in
            pointer.pointee.clazz = DXFG_EVENT_SUMMARY
            return pointer
        }
        return eventType
    }
}
