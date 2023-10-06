//
//  Greeks+Ext.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 06.10.23.
//

import Foundation
@_implementationOnly import graal_api

extension Greeks {
    convenience init(native: dxfg_greeks_t) {
        self.init(String(pointee: native.market_event.event_symbol))
        self.eventTime = native.market_event.event_time
        self.eventFlags = native.event_flags
        self.index = native.index
        self.price = native.price
        self.volatility = native.volatility
        self.delta = native.delta
        self.gamma = native.gamma
        self.theta = native.theta
        self.rho = native.rho
        self.vega = native.vega
    }
}
