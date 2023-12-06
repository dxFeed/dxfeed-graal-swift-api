//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
        pointer.pointee.market_event.event_symbol = event.eventSymbol.toCStringRef()
        pointer.pointee.market_event.event_time = event.eventTime

        let summary = event.summary
        pointer.pointee.day_id = summary.dayId
        pointer.pointee.day_open_price = summary.dayOpenPrice
        pointer.pointee.day_high_price = summary.dayHighPrice
        pointer.pointee.day_low_price = summary.dayLowPrice
        pointer.pointee.day_close_price = summary.dayClosePrice
        pointer.pointee.prev_day_id = summary.prevDayId
        pointer.pointee.prev_day_close_price = summary.prevDayClosePrice
        pointer.pointee.prev_day_volume = summary.prevDayVolume
        pointer.pointee.open_interest = summary.openInterest
        pointer.pointee.flags = summary.flags

        let eventType = pointer.withMemoryRebound(to: dxfg_event_type_t.self, capacity: 1) { pointer in
            pointer.pointee.clazz = DXFG_EVENT_SUMMARY
            return pointer
        }
        return eventType
    }
}
