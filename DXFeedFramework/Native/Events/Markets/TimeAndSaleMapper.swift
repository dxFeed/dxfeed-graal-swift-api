//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
        pointer.pointee.market_event.event_symbol = event.eventSymbol.toCStringRef()
        pointer.pointee.market_event.event_time = event.eventTime

        let timeAndSale = event.timeAndSale
        pointer.pointee.event_flags = timeAndSale.eventFlags
        pointer.pointee.index = timeAndSale.index
        pointer.pointee.time_nano_part = timeAndSale.timeNanoPart
        pointer.pointee.exchange_code = timeAndSale.exchangeCode
        pointer.pointee.price = timeAndSale.price
        pointer.pointee.size = timeAndSale.size
        pointer.pointee.bid_price = timeAndSale.bidPrice
        pointer.pointee.ask_price = timeAndSale.askPrice
        pointer.pointee.exchange_sale_conditions = timeAndSale.exchangeSaleConditions?.toCStringRef()
        pointer.pointee.flags = timeAndSale.flags
        pointer.pointee.buyer = timeAndSale.buyer?.toCStringRef()
        pointer.pointee.seller = timeAndSale.seller?.toCStringRef()
        let eventType = pointer.withMemoryRebound(to: dxfg_event_type_t.self, capacity: 1) { pointer in
            pointer.pointee.clazz = DXFG_EVENT_TIME_AND_SALE
            return pointer
        }
        return eventType
    }
}
