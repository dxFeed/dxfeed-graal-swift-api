//
//  InstrumentProfileMapper.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 29.08.23.
//

import Foundation
@_implementationOnly import graal_api

class InstrumentProfileMapper {

    func fromNative(native: UnsafeMutablePointer<dxfg_instrument_profile_t>) -> InstrumentProfile {
        let event = InstrumentProfile(native: native.pointee)
        return event
    }

    func toNative(instrumentProfile: InstrumentProfile) -> UnsafeMutablePointer<dxfg_instrument_profile_t> {
        let pointer = UnsafeMutablePointer<dxfg_instrument_profile_t>.allocate(capacity: 1)
        instrumentProfile.copy(to: pointer)
        return pointer

    }

    func releaseNative(native: UnsafeMutablePointer<dxfg_instrument_profile_t>) {
        native.deinitialize(count: 1)
        native.deallocate()
    }

}
