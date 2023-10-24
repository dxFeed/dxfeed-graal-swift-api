//
//  Profile+Ext.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 07.06.23.
//

import Foundation
@_implementationOnly import graal_api

extension Profile {
    convenience init(native: dxfg_profile_t) {
        self.init(String(pointee: native.market_event.event_symbol))
        self.eventTime = native.market_event.event_time
        self.descriptionStr = String(nullable: native.description)
        self.statusReason = String(nullable: native.status_reason)
        self.haltStartTime = native.halt_start_time
        self.haltEndTime = native.halt_end_time
        self.highLimitPrice = native.high_limit_price
        self.lowLimitPrice = native.low_limit_price
        self.high52WeekPrice = native.high_52_week_price
        self.low52WeekPrice = native.low_52_week_price
        self.beta = native.beta
        self.earningsPerShare = native.earnings_per_share
        self.dividendFrequency = native.dividend_frequency
        self.exDividendAmount = native.ex_dividend_amount
        self.exDividendDayId = native.ex_dividend_day_id
        self.shares = native.shares
        self.freeFloat = native.free_float
        self.flags = native.flags
    }
}
