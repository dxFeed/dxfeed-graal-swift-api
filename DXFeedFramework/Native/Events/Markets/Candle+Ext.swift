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
        self.init()
        self.eventSymbol = String(pointee: native.event_symbol)
        self.eventTime = native.event_time
        self.eventFlags = native.event_flags
        self.index = native.index
        self.count = native.count
        self.open = native.open
        self.high = native.high
        self.low = native.low
        self.close = native.close
        self.volume = native.volume
        self.vwap = native.vwap
        self.bidVolume = native.bid_volume
        self.askVolume = native.ask_volume
        self.impVolatility = native.imp_volatility
        self.openInterest = native.open_interest
    }
}
