//
//  Mapper.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 05.06.23.
//

import Foundation
@_implementationOnly import graal_api

protocol Mapper {
    func fromNative(native: UnsafeMutablePointer<dxfg_event_type_t>) throws -> MarketEvent?
    func toNative(event: MarketEvent) throws -> UnsafeMutablePointer<dxfg_event_type_t>?
}
