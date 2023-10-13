//
//  Series+Ext.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 12.10.23.
//

import Foundation
@_implementationOnly import graal_api

extension Series {
    convenience init(native: dxfg_series_t) {
        self.init(String(pointee: native.market_event.event_symbol))

        self.eventTime = native.market_event.event_time
        self.eventFlags = native.event_flags
        self.index = native.index
        self.timeSequence = native.time_sequence
        self.expiration = native.expiration
        self.volatility = native.volatility
        self.callVolume = native.call_volume
        self.putVolume = native.put_volume
        self.putCallRatio = native.put_call_ratio
        self.forwardPrice = native.forward_price
        self.dividend = native.dividend
        self.interest = native.interest
    }
}
