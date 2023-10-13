//
//  OptionSaleMapper.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 13.10.23.
//

import Foundation
@_implementationOnly import graal_api

class OptionSaleMapper: Mapper {
    let type = dxfg_option_sale_t.self

    func fromNative(native: UnsafeMutablePointer<dxfg_event_type_t>) -> MarketEvent? {
        let event = native.withMemoryRebound(to: type, capacity: 1) { native in
            return OptionSale(native: native.pointee)
        }
        return event
    }

    func toNative(event: MarketEvent) -> UnsafeMutablePointer<dxfg_event_type_t>? {
        let pointer = UnsafeMutablePointer<TypeAlias>.allocate(capacity: 1)
        var pointee = pointer.pointee
        pointee.market_event.event_symbol = event.eventSymbol.toCStringRef()
        pointee.market_event.event_time = event.eventTime

        let optionSale = event.optionSale

        pointee.event_flags = optionSale.eventFlags
        pointee.index = optionSale.index
        pointee.time_sequence = optionSale.timeSequence
        pointee.time_nano_part = optionSale.timeNanoPart
        pointee.exchange_code = optionSale.exchangeCode
        pointee.price = optionSale.price
        pointee.size = optionSale.size
        pointee.bid_price = optionSale.bidPrice
        pointee.ask_price = optionSale.askPrice
        pointee.exchange_sale_conditions = optionSale.exchangeSaleConditions.toCStringRef()
        pointee.flags = optionSale.flags
        pointee.underlying_price = optionSale.underlyingPrice
        pointee.volatility = optionSale.volatility
        pointee.delta = optionSale.delta
        pointee.option_symbol = optionSale.optionSymbol.toCStringRef()        

        let eventType = pointer.withMemoryRebound(to: dxfg_event_type_t.self, capacity: 1) { pointer in
            pointer.pointee.clazz = DXFG_EVENT_OPTION_SALE
            return pointer
        }
        return eventType
    }
}
