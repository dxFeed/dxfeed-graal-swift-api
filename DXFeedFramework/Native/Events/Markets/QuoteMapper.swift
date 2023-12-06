//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
@_implementationOnly import graal_api

class QuoteMapper: Mapper {
    var type = dxfg_quote_t.self

    func fromNative(native: UnsafeMutablePointer<dxfg_event_type_t>) -> MarketEvent? {
        let event = native.withMemoryRebound(to: type, capacity: 1) { native in
            return Quote(native: native.pointee)
        }
        return event
    }

    func toNative(event: MarketEvent) -> UnsafeMutablePointer<dxfg_event_type_t>? {
        let pointer = UnsafeMutablePointer<dxfg_quote_t>.allocate(capacity: 1)

        pointer.pointee.market_event.event_symbol = event.eventSymbol.toCStringRef()
        pointer.pointee.market_event.event_time = event.eventTime

        let quote = event.quote
        pointer.pointee.time_millis_sequence = quote.timeMillisSequence
        pointer.pointee.time_nano_part = quote.timeNanoPart
        pointer.pointee.bid_time = quote.bidTime
        pointer.pointee.bid_exchange_code = quote.bidExchangeCode
        pointer.pointee.bid_price = quote.bidPrice
        pointer.pointee.bid_size = quote.bidSize
        pointer.pointee.ask_time = quote.askTime
        pointer.pointee.ask_exchange_code = quote.askExchangeCode
        pointer.pointee.ask_price = quote.askPrice
        pointer.pointee.ask_size = quote.askSize

        let eventType = pointer.withMemoryRebound(to: dxfg_event_type_t.self, capacity: 1) { pointer in
            pointer.pointee.clazz = DXFG_EVENT_QUOTE
            return pointer
        }
        return eventType
    }

}
