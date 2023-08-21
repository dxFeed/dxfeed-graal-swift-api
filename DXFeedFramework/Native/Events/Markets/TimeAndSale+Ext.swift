//
//  TimeAndSale+Ext.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 06.06.23.
//

import Foundation
@_implementationOnly import graal_api

extension TimeAndSale {
    convenience init(native: dxfg_time_and_sale_t) {
        self.init(String(pointee: native.market_event.event_symbol))
        self.eventTime = native.market_event.event_time
        self.eventFlags = native.event_flags
        self.index = native.index
        self.timeNanoPart = native.time_nano_part
        self.exchangeCode = native.exchange_code
        self.price = native.price
        self.size = native.size
        self.bidPrice = native.bid_price
        self.askPrice = native.ask_price
        self.exchangeSaleConditions = String(pointee: native.exchange_sale_conditions)
        self.flags = native.flags
        self.buyer = String(pointee: native.buyer)
        self.seller = String(pointee: native.seller)
    }
}
