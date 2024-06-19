//
//  Quote+Ext.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 06.06.23.
//

import Foundation
@_implementationOnly import graal_api

extension Quote {
    convenience init(native: dxfg_quote_t) {
        self.init(eventSymbol: String(pointee: native.market_event.event_symbol),
                  eventTime: native.market_event.event_time,
                  timeMillisSequence: native.time_millis_sequence,
                  timeNanoPart: native.time_nano_part,
                  bidTime: native.bid_time,
                  bidExchangeCode: native.bid_exchange_code,
                  bidPrice: native.bid_price,
                  bidSize: native.bid_size,
                  askTime: native.ask_time,
                  askExchangeCode: native.ask_exchange_code,
                  askPrice: native.ask_price,
                  askSize: native.ask_size)
    }
}
