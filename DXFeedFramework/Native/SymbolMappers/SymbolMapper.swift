//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
        case INDEXED_EVENT_SUBSCRIPTION: fatalError("Add case for INDEXED_EVENT_SUBSCRIPTION")
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

    static func newSymbols(symbols: UnsafeMutablePointer<dxfg_symbol_list>) -> [AnyHashable] {
        var results = [AnyHashable]()
        for index in 0..<Int(symbols.pointee.size) {
            if let symbol = symbols.pointee.elements[index] {
                if let result = newSymbol(native: symbol) {
                    results.append(result)
                }
            }
        }
        return results
    }

    private static func newSymbol(native: UnsafeMutablePointer<dxfg_symbol_t>) -> AnyHashable? {
        let type = native.pointee.type
        switch type {
        case STRING:
            let result = native.withMemoryRebound(to: dxfg_string_symbol_t.self, capacity: 1) { pointer in
                String(pointee: pointer.pointee.symbol)
            }
            return result
        case CANDLE:
            let result = native.withMemoryRebound(to: dxfg_candle_symbol_t.self, capacity: 1) { pointer in
                String(pointee: pointer.pointee.symbol)
            }
            return result
        case WILDCARD:
            return WildcardSymbol.all
        case INDEXED_EVENT_SUBSCRIPTION: fatalError("Add case for INDEXED_EVENT_SUBSCRIPTION")
        case TIME_SERIES_SUBSCRIPTION:
            let result: TimeSeriesSubscriptionSymbol? = native.withMemoryRebound(
                to: dxfg_time_series_subscription_symbol_t.self, capacity: 1) { pointer in
                if let symbol = SymbolMapper.newSymbol(native: pointer.pointee.symbol) {
                    return TimeSeriesSubscriptionSymbol(symbol: symbol, fromTime: pointer.pointee.from_time)
                } else {
                    return nil
                }
            }
            return result
        default: break
        }

        return nil
    }
}
