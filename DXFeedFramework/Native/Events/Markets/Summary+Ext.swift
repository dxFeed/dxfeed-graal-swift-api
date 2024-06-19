//
//  Summary+Ext.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 06.10.23.
//

import Foundation
@_implementationOnly import graal_api

extension Summary {
    convenience init(native: dxfg_summary_t) {
        self.init(String(pointee: native.market_event.event_symbol))
        self.eventTime = native.market_event.event_time
        self.dayId = native.day_id
        self.dayOpenPrice = native.day_open_price
        self.dayHighPrice = native.day_high_price
        self.dayLowPrice = native.day_low_price
        self.dayClosePrice = native.day_close_price
        self.prevDayId = native.prev_day_id
        self.prevDayClosePrice = native.prev_day_close_price
        self.prevDayVolume = native.prev_day_volume
        self.openInterest = native.open_interest
        self.flags = native.flags
    }
}
