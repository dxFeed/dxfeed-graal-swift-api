//
//  CandleMapper.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 13.07.23.
//

@_implementationOnly import graal_api

class CandleMapper: Mapper {
    func fromNative(native: UnsafeMutablePointer<dxfg_event_type_t>) -> MarketEvent? {
        let event = native.withMemoryRebound(to: dxfg_candle_t.self, capacity: 1) { native in
            return Candle(native: native.pointee)
        }
        return event
    }

    func toNative(event: MarketEvent) -> UnsafeMutablePointer<dxfg_event_type_t>? {
        let pointer = UnsafeMutablePointer<dxfg_candle_t>.allocate(capacity: 1)
#warning("TODO: implement it")
        let eventType = pointer.withMemoryRebound(to: dxfg_event_type_t.self, capacity: 1) { pointer in
            return pointer
        }
        return eventType
    }
}

