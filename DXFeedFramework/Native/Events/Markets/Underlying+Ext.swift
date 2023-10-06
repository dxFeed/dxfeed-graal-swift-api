//
//  Underlying+Ext.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 06.10.23.
//

import Foundation
@_implementationOnly import graal_api

extension Underlying {
    convenience init(native: dxfg_underlying_t) {
        self.init(String(pointee: native.market_event.event_symbol))

        self.eventTime = native.market_event.event_time
        self.eventFlags = native.event_flags
        self.index = native.index
        self.volatility = native.volatility
        self.frontVolatility = native.front_volatility
        self.backVolatility = native.back_volatility
        self.callVolume = native.call_volume
        self.putVolume = native.put_volume
        self.putCallRatio = native.put_call_ratio
    }
}
