//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
@_implementationOnly import graal_api

class GreeksMapper: Mapper {
    let type = dxfg_greeks_t.self

    func fromNative(native: UnsafeMutablePointer<dxfg_event_type_t>) -> MarketEvent? {
        let event = native.withMemoryRebound(to: type, capacity: 1) { native in
            return Greeks(native: native.pointee)
        }
        return event
    }

    func toNative(event: MarketEvent) -> UnsafeMutablePointer<dxfg_event_type_t>? {
        let pointer = UnsafeMutablePointer<dxfg_greeks_t>.allocate(capacity: 1)
        pointer.pointee.market_event.event_symbol = event.eventSymbol.toCStringRef()
        pointer.pointee.market_event.event_time = event.eventTime

        let greeks = event.greeks
        pointer.pointee.event_flags = greeks.eventFlags
        pointer.pointee.index = greeks.index
        pointer.pointee.price = greeks.price
        pointer.pointee.volatility = greeks.volatility
        pointer.pointee.delta = greeks.delta
        pointer.pointee.gamma = greeks.gamma
        pointer.pointee.theta = greeks.theta
        pointer.pointee.rho = greeks.rho
        pointer.pointee.vega = greeks.vega

        let eventType = pointer.withMemoryRebound(to: dxfg_event_type_t.self, capacity: 1) { pointer in
            pointer.pointee.clazz = DXFG_EVENT_GREEKS
            return pointer
        }
        return eventType
    }
}
