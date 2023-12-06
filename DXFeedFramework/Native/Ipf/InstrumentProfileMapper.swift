//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
        native.pointee.custom_fields.deinitialize(count: 1)
        native.pointee.custom_fields.deallocate()
        native.deinitialize(count: 1)
        native.deallocate()
    }
}
