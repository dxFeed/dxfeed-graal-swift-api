//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
        pointer.pointee.market_event.event_symbol = event.eventSymbol.toCStringRef()
        pointer.pointee.market_event.event_time = event.eventTime

        let optionSale = event.optionSale

        pointer.pointee.event_flags = optionSale.eventFlags
        pointer.pointee.index = optionSale.index
        pointer.pointee.time_sequence = optionSale.timeSequence
        pointer.pointee.time_nano_part = optionSale.timeNanoPart
        pointer.pointee.exchange_code = optionSale.exchangeCode
        pointer.pointee.price = optionSale.price
        pointer.pointee.size = optionSale.size
        pointer.pointee.bid_price = optionSale.bidPrice
        pointer.pointee.ask_price = optionSale.askPrice
        pointer.pointee.exchange_sale_conditions = optionSale.exchangeSaleConditions?.toCStringRef()
        pointer.pointee.flags = optionSale.flags
        pointer.pointee.underlying_price = optionSale.underlyingPrice
        pointer.pointee.volatility = optionSale.volatility
        pointer.pointee.delta = optionSale.delta
        pointer.pointee.option_symbol = optionSale.optionSymbol?.toCStringRef()

        let eventType = pointer.withMemoryRebound(to: dxfg_event_type_t.self, capacity: 1) { pointer in
            pointer.pointee.clazz = DXFG_EVENT_OPTION_SALE
            return pointer
        }
        return eventType
    }
}
