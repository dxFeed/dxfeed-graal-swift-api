//
//  Candle+Ext.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 13.07.23.
//

import Foundation
@_implementationOnly import graal_api

extension Candle {
    convenience init(native: dxfg_candle_t) {
        self.init(eventSymbol: String(pointee: native.event_symbol),
            eventTime: native.event_time,
            eventFlags: native.event_flags,
            index: native.index,
            count: native.count,
            open: native.open,
            high: native.high,
            low: native.low,
            close: native.close,
            volume: native.volume,
            vwap: native.vwap,
            bidVolume: native.bid_volume,
            askVolume: native.ask_volume,
            impVolatility: native.imp_volatility,
            openInterest: native.open_interest)
    }
}
