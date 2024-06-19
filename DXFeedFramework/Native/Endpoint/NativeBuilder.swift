//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
@_implementationOnly import graal_api

/// Native wrapper over the Java com.dxfeed.api.DXEndpoint.Builder class.
class NativeBuilder {
    let builder: UnsafeMutablePointer<dxfg_endpoint_builder_t>?
    var role = Role.feed
    deinit {
        if let builder = self.builder {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread,
                                           dxfg_JavaObjectHandler_release(thread, &(builder.pointee.handler)))
        }
    }

    init() throws {
        let thread = currentThread()
        self.builder = try ErrorCheck.nativeCall(thread, dxfg_DXEndpoint_newBuilder(thread))
    }

    func isSuppored(property: String) throws -> Bool {
        let thread = currentThread()
        let res = try ErrorCheck.nativeCall(thread,
                                            dxfg_DXEndpoint_Builder_supportsProperty(thread,
                                                                                     self.builder,
                                                                                     property.cString(using: .utf8)))
        return res != 0
    }

    func withRole(_ role: Role) throws -> Bool {
        let thread = currentThread()
        let res = try ErrorCheck.nativeCall(thread,
                                            dxfg_DXEndpoint_Builder_withRole(thread,
                                                                             builder,
                                                                             role.toNatie()
                                                                            )
        )
        return res != 0
    }

    func withProperty(_ key: String, _ value: String) throws {
        let thread = currentThread()
         _ = try ErrorCheck.nativeCall(thread,
                                       dxfg_DXEndpoint_Builder_withProperty(thread,
                                                                           self.builder,
                                                                           key.cString(using: .utf8),
                                                                           value.cString(using: .utf8)))
    }

    func build() throws -> NativeEndpoint {
        let thread = currentThread()
        let value = try ErrorCheck.nativeCall(thread, dxfg_DXEndpoint_Builder_build(thread, builder)).value()
        return NativeEndpoint(value)
    }
}
