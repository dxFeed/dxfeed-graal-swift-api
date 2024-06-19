//
//  EventMapper.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 05.06.23.
//

import Foundation
@_implementationOnly import graal_api

class EventMapper: Mapper {
    typealias TypeAlias = dxfg_event_type_t
    var type: dxfg_event_type_t.Type

    init() {
        self.type = dxfg_event_type_t.self
    }

    private let mappers: [EventCode: any Mapper] = [.quote: QuoteMapper(),
                                                .timeAndSale: TimeAndSaleMapper(),
                                                .profile: ProfileMapper(),
                                                .trade: TradeMapper(),
                                                .candle: CandleMapper()]

    func fromNative(native: UnsafeMutablePointer<dxfg_event_type_t>) throws -> MarketEvent? {
        let code = try EnumUtil.valueOf(value: EventCode.convert(native.pointee.clazz))
        if let mapper = mappers[code] {
            return try mapper.fromNative(native: native)
        }
        return nil
    }

    func toNative(event: MarketEvent) throws -> UnsafeMutablePointer<dxfg_event_type_t>? {
        let code = event.type
        if let mapper = mappers[code] {
            return try mapper.toNative(event: event)
        }
        return nil
    }

    func releaseNative(native: UnsafeMutablePointer<dxfg_event_type_t>) {
        if let code = try? EnumUtil.valueOf(value: EventCode.convert(native.pointee.clazz)) {
            if let mapper = mappers[code] {
                mapper.releaseNative(native: native)
            }
        }
    }
}
