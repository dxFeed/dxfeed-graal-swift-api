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
        self.init(String(pointee: native.market_event.event_symbol))

        self.eventTime = native.market_event.event_time
        self.timeSequence = native.time_sequence
        self.timeNanoPart = native.time_nano_part
        self.exchangeCode = native.exchange_code
        self.price = native.price
        self.change = native.change
        self.size = native.size
        self.dayId = native.day_id
        self.dayVolume = native.day_volume
        self.dayTurnover = native.day_turnover
        self.flags = native.flags
    }
}
