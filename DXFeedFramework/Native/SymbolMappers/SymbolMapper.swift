//
//  SymbolMapper.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 01.06.23.
//

import Foundation
@_implementationOnly import graal_api

class SymbolMapper {

    static func newNative(_ symbol: Any) -> UnsafeMutablePointer<dxfg_symbol_t>? {
        switch symbol {
        case let stringSymbol as String:
            let pointer = UnsafeMutablePointer<dxfg_string_symbol_t>.allocate(capacity: 1)
            pointer.pointee.supper = dxfg_symbol_t(type: STRING)
            pointer.pointee.symbol = stringSymbol.stringValue.toCStringRef()
            let casted = pointer.withMemoryRebound(to: dxfg_symbol_t.self, capacity: 1) { $0 }
            return casted
        case _ as WildcardSymbol:
            let pointer = UnsafeMutablePointer<dxfg_wildcard_symbol_t>.allocate(capacity: 1)
            pointer.pointee.supper = dxfg_symbol_t(type: WILDCARD)
            let casted = pointer.withMemoryRebound(to: dxfg_symbol_t.self, capacity: 1) { $0 }
            return casted
        case let candleSymbol as CandleSymbol:
            let pointer = UnsafeMutablePointer<dxfg_candle_symbol_t>.allocate(capacity: 1)
            pointer.pointee.supper =  dxfg_symbol_t(type: CANDLE)
            pointer.pointee.symbol = candleSymbol.symbol?.toCStringRef()
            let casted = pointer.withMemoryRebound(to: dxfg_symbol_t.self, capacity: 1) { $0 }
            return casted
        case let symbol as TimeSeriesSubscriptionSymbol:
            let pointer = UnsafeMutablePointer<dxfg_time_series_subscription_symbol_t>.allocate(capacity: 1)
            pointer.pointee.supper = dxfg_symbol_t(type: TIME_SERIES_SUBSCRIPTION)
            pointer.pointee.symbol = newNative(symbol.symbol)
            pointer.pointee.from_time = symbol.fromTime
            let casted = pointer.withMemoryRebound(to: dxfg_symbol_t.self, capacity: 1) { $0 }
            return casted
        default:
            let pointer = UnsafeMutablePointer<dxfg_string_symbol_t>.allocate(capacity: 1)
            pointer.pointee.supper = dxfg_symbol_t(type: STRING)
            if symbol is Symbol {
                pointer.pointee.symbol = (symbol as? Symbol)?.stringValue.toCStringRef()
            }
            let casted = pointer.withMemoryRebound(to: dxfg_symbol_t.self, capacity: 1) { $0 }
            return casted
        }
    }

    static func clearNative(symbol: UnsafeMutablePointer<dxfg_symbol_t>) {
        let type = symbol.pointee.type
        switch type {
        case STRING:
            symbol.withMemoryRebound(to: dxfg_string_symbol_t.self, capacity: 1) {
                $0.deinitialize(count: 1)
                $0.deallocate()
            }
        case CANDLE:
            symbol.withMemoryRebound(to: dxfg_candle_symbol_t.self, capacity: 1) {
                $0.deinitialize(count: 1)
                $0.deallocate()
            }

        case WILDCARD: break
        case INDEXED_EVENT_SUBSCRIPTION: break
        case TIME_SERIES_SUBSCRIPTION:
            symbol.withMemoryRebound(to: dxfg_time_series_subscription_symbol_t.self, capacity: 1) {
                clearNative(symbol: $0.pointee.symbol)
                $0.deinitialize(count: 1)
                $0.deallocate()
            }
        default:
            symbol.deinitialize(count: 1)
            symbol.deallocate()
        }
    }
}
