//
//  ProfileMapper.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 07.06.23.
//

import Foundation
@_implementationOnly import graal_api

class ProfileMapper: Mapper {
    let type = dxfg_profile_t.self

    func fromNative(native: UnsafeMutablePointer<dxfg_event_type_t>) -> MarketEvent? {
        let event = native.withMemoryRebound(to: type, capacity: 1) { native in
            return Profile(native: native.pointee)
        }
        return event
    }

    func toNative(event: MarketEvent) -> UnsafeMutablePointer<dxfg_event_type_t>? {
        let pointer = UnsafeMutablePointer<dxfg_profile_t>.allocate(capacity: 1)
        var pointee = pointer.pointee
        pointee.market_event.event_symbol = event.eventSymbol.toCStringRef()
        pointee.market_event.event_time = event.eventTime

        let profile = event.profile
        pointee.description = profile.descriptionStr?.toCStringRef()
        pointee.status_reason = profile.statusReason?.toCStringRef()
        pointee.halt_start_time = profile.haltStartTime
        pointee.halt_end_time = profile.haltEndTime
        pointee.high_limit_price = profile.highLimitPrice
        pointee.low_limit_price = profile.lowLimitPrice
        pointee.high_52_week_price = profile.high52WeekPrice
        pointee.low_52_week_price = profile.low52WeekPrice
        pointee.beta = profile.beta
        pointee.earnings_per_share = profile.earningsPerShare
        pointee.dividend_frequency = profile.dividendFrequency
        pointee.ex_dividend_amount = profile.exDividendAmount
        pointee.ex_dividend_day_id = profile.exDividendDayId
        pointee.shares = profile.shares
        pointee.free_float = profile.freeFloat
        pointee.flags = profile.flags
        let eventType = pointer.withMemoryRebound(to: dxfg_event_type_t.self, capacity: 1) { pointer in
            pointer.pointee.clazz = DXFG_EVENT_PROFILE
            return pointer
        }
        return eventType
    }
}
