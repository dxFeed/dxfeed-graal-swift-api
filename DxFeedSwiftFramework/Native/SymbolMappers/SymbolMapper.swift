//
//  SymbolMapper.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 01.06.23.
//

import Foundation
@_implementationOnly import graal_api

class SymbolMapper {

    static func newNative(_ symbol: Symbol) -> UnsafeMutablePointer<dxfg_symbol_t>? {
        switch symbol {
        case let stringSymbol as String:
            var pointer = UnsafeMutablePointer<dxfg_string_symbol_t>.allocate(capacity: 1)
            pointer.pointee.supper = dxfg_symbol_t(type: STRING)
            pointer.pointee.symbol = stringSymbol.stringValue.toCStringRef()
            print(String(pointee: pointer.pointee.symbol, default: "ooops"))
            let casted = pointer.withMemoryRebound(to: dxfg_symbol_t.self, capacity: 1) { $0 }
            return casted
        case _ as WildcardSymbol:
            let pointer = UnsafeMutablePointer<dxfg_wildcard_symbol_t>.allocate(capacity: 1)
            pointer.pointee.supper = dxfg_symbol_t(type: WILDCARD)
            let casted = pointer.withMemoryRebound(to: dxfg_symbol_t.self, capacity: 1) { $0 }
            return casted
        case let tsSymbol as TimeSeriesSubscriptionSymbol:
            print(tsSymbol)
        default:
            let pointer = UnsafeMutablePointer<dxfg_string_symbol_t>.allocate(capacity: 1)
            pointer.pointee.supper = dxfg_symbol_t(type: STRING)
            pointer.pointee.symbol = symbol.stringValue.toCStringRef()
            let casted = pointer.withMemoryRebound(to: dxfg_symbol_t.self, capacity: 1) { $0 }
            return casted
        }
        return nil
    }

    static func clearNative(symbol: UnsafeMutablePointer<dxfg_symbol_t>) {
        let type = symbol.pointee.type
        switch type {
        case STRING:
#warning("TODO: implement correct deinit. re-cast to specific object")
            symbol.withMemoryRebound(to: dxfg_string_symbol_t.self, capacity: 1) {
                $0.deinitialize(count: 1)
                $0.deallocate()
            }
        case CANDLE: break
        case WILDCARD: break
        case INDEXED_EVENT_SUBSCRIPTION: break
        case TIME_SERIES_SUBSCRIPTION: break
        default:
            symbol.deinitialize(count: 1)
            symbol.deallocate()
        }
    }
}
