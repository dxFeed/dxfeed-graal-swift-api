//
//  TheoPrice+Ext.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 06.10.23.
//

import Foundation
@_implementationOnly import graal_api

extension TheoPrice {
    convenience init(native: dxfg_theo_price_t) {
        self.init(String(pointee: native.market_event.event_symbol))

        self.eventTime = native.market_event.event_time
        self.eventFlags = native.event_flags
        self.index = native.index
        
        self.price = native.price
        self.underlyingPrice = native.underlying_price
        self.delta = native.delta
        self.gamma = native.gamma
        self.dividend = native.dividend
        self.interest = native.interest
    }
}
