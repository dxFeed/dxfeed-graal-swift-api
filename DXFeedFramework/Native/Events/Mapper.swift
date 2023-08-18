//
//  Mapper.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 05.06.23.
//

import Foundation
@_implementationOnly import graal_api

protocol Mapper {
    associatedtype TypeAlias
    var type: TypeAlias.Type { get }

    func fromNative(native: UnsafeMutablePointer<dxfg_event_type_t>) throws -> MarketEvent?
    func toNative(event: MarketEvent) throws -> UnsafeMutablePointer<dxfg_event_type_t>?
    func releaseNative(native: UnsafeMutablePointer<dxfg_event_type_t>)
}

extension Mapper {
    func releaseNative(native: UnsafeMutablePointer<dxfg_event_type_t>) {
        native.withMemoryRebound(to: type, capacity: 1) { native in
            native.deinitialize(count: 1)
            native.deallocate()
        }
    }
}
