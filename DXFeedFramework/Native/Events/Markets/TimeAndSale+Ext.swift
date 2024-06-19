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
        self.init(eventSymbol: String(pointee: native.market_event.event_symbol),
                  eventTime: native.market_event.event_time,
                  eventFlags: native.event_flags,
                  index: native.index,
                  timeNanoPart: native.time_nano_part,
                  exchangeCode: native.exchange_code,
                  price: native.price,
                  size: native.size,
                  bidPrice: native.bid_price,
                  askPrice: native.ask_price,
                  exchangeSaleConditions: String(pointee: native.exchange_sale_conditions),
                  flags: native.flags,
                  buyer: String(pointee: native.buyer),
                  seller: String(pointee: native.seller))
    }
}
