//
//  TimeAndSaleMapper.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 06.06.23.
//

import Foundation
@_implementationOnly import graal_api

class TimeAndSaleMapper: Mapper {
    let type = dxfg_time_and_sale_t.self

    func fromNative(native: UnsafeMutablePointer<dxfg_event_type_t>) -> MarketEvent? {
        let event = native.withMemoryRebound(to: type, capacity: 1) { native in
            return TimeAndSale(native: native.pointee)
        }
        return event
    }

    func toNative(event: MarketEvent) -> UnsafeMutablePointer<dxfg_event_type_t>? {
        let pointer = UnsafeMutablePointer<dxfg_time_and_sale_t>.allocate(capacity: 1)
        var pointee = pointer.pointee
        let timeAndSale = event.timeAndSale
        pointee.event_flags = timeAndSale.eventFlags
        pointee.index = timeAndSale.index
        pointee.time_nano_part = timeAndSale.timeNanoPart
        pointee.exchange_code = timeAndSale.exchangeCode
        pointee.price = timeAndSale.price
        pointee.size = timeAndSale.size
        pointee.bid_price = timeAndSale.bidPrice
        pointee.ask_price = timeAndSale.askPrice
        pointee.exchange_sale_conditions = timeAndSale.exchangeSaleConditions.toCStringRef()
        pointee.flags = timeAndSale.flags
        pointee.buyer = timeAndSale.buyer.toCStringRef()
        pointee.seller = timeAndSale.seller.toCStringRef()
        let eventType = pointer.withMemoryRebound(to: dxfg_event_type_t.self, capacity: 1) { pointer in
            pointer.pointee.clazz = DXFG_EVENT_TIME_AND_SALE
            return pointer
        }
        return eventType
    }
}
