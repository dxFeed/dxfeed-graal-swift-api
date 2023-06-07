//
//  ProfileMapper.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 07.06.23.
//

import Foundation
@_implementationOnly import graal_api

class ProfileMapper: Mapper {
    func fromNative(native: UnsafeMutablePointer<dxfg_event_type_t>) -> MarketEvent? {
        let event = native.withMemoryRebound(to: dxfg_profile_t.self, capacity: 1) { native in
            return Profile(native: native.pointee)
        }
        return event
    }

    func toNative(event: MarketEvent) -> UnsafeMutablePointer<dxfg_event_type_t>? {
        let pointer = UnsafeMutablePointer<dxfg_profile_t>.allocate(capacity: 1)
#warning("TODO: implement it")
        let eventType = pointer.withMemoryRebound(to: dxfg_event_type_t.self, capacity: 1) { pointer in
            return pointer
        }
        return eventType
    }
}
