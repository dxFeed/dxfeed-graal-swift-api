//
//  EventMapper.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 05.06.23.
//

import Foundation
@_implementationOnly import graal_api

class EventMapper: Mapper {
    private let mappers: [EventCode: Mapper] = [.quote: QuoteMapper(),
                                                .timeAndSale: TimeAndSaleMapper()]

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
}
