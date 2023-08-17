//
//  Trade+Ext.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 07.06.23.
//

import Foundation
@_implementationOnly import graal_api

extension Trade {
    convenience init(native: dxfg_trade_base_t) {
        self.init(type: .trade,
            eventSymbol: String(pointee: native.market_event.event_symbol),
            eventTime: native.market_event.event_time,
            timeSequence: native.time_sequence,
            timeNanoPart: native.time_nano_part,
            exchangeCode: native.exchange_code,
            price: native.price,
            change: native.change,
            size: native.size,
            dayId: native.day_id,
            dayVolume: native.day_volume,
            dayTurnover: native.day_turnover,
            flags: native.flags)
    }
}
