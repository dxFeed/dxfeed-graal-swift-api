//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
        pointer.pointee.market_event.event_symbol = event.eventSymbol.toCStringRef()
        pointer.pointee.market_event.event_time = event.eventTime

        let profile = event.profile
        pointer.pointee.description = profile.descriptionStr?.toCStringRef()
        pointer.pointee.status_reason = profile.statusReason?.toCStringRef()
        pointer.pointee.halt_start_time = profile.haltStartTime
        pointer.pointee.halt_end_time = profile.haltEndTime
        pointer.pointee.high_limit_price = profile.highLimitPrice
        pointer.pointee.low_limit_price = profile.lowLimitPrice
        pointer.pointee.high_52_week_price = profile.high52WeekPrice
        pointer.pointee.low_52_week_price = profile.low52WeekPrice
        pointer.pointee.beta = profile.beta
        pointer.pointee.earnings_per_share = profile.earningsPerShare
        pointer.pointee.dividend_frequency = profile.dividendFrequency
        pointer.pointee.ex_dividend_amount = profile.exDividendAmount
        pointer.pointee.ex_dividend_day_id = profile.exDividendDayId
        pointer.pointee.shares = profile.shares
        pointer.pointee.free_float = profile.freeFloat
        pointer.pointee.flags = profile.flags
        let eventType = pointer.withMemoryRebound(to: dxfg_event_type_t.self, capacity: 1) { pointer in
            pointer.pointee.clazz = DXFG_EVENT_PROFILE
            return pointer
        }
        return eventType
    }
}
