//
//  Profile+Ext.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 07.06.23.
//

import Foundation
@_implementationOnly import graal_api

extension Profile {
    convenience init(native: dxfg_profile_t) {
        self.init(eventSymbol: String(pointee: native.market_event.event_symbol),
            eventTime: native.market_event.event_time,
            description: String(pointee: native.description),
            statusReason: String(pointee: native.status_reason),
            haltStartTime: native.halt_start_time,
            haltEndTime: native.halt_end_time,
            highLimitPrice: native.high_limit_price,
            lowLimitPrice: native.low_limit_price,
            high52WeekPrice: native.high_52_week_price,
            low52WeekPrice: native.low_52_week_price,
            beta: native.beta,
            earningsPerShare: native.earnings_per_share,
            dividendFrequency: native.dividend_frequency,
            exDividendAmount: native.ex_dividend_amount,
            exDividendDayId: native.ex_dividend_day_id,
            shares: native.shares,
            freeFloat: native.free_float,
            flags: native.flags)
    }
}
