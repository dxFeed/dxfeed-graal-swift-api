//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
@_implementationOnly import graal_api

/// Native wrapper over the Java java.lang.System class, contains work with property getter/setter methods.
/// In Java world, these properties can be set by passing the "-Dprop=value" argument in command line
/// or calls java.lang.System.setProperty(String key, String value).
/// The location of the imported functions is in the header files "dxfg_system.h".
class NativeProperty {
    static func setProperty(_ key: String, _ value: String) throws {
        let thread =  currentThread()
        try ErrorCheck.nativeCall(thread,
                                  dxfg_system_set_property(thread,
                                                           key.cString(using: .utf8),
                                                           value.cString(using: .utf8))
        )
    }

    static func getProperty(_ key: String) -> String? {
        let thread = currentThread()
        if let property = try? ErrorCheck.nativeCall(thread,
                                                     dxfg_system_get_property(
                                                        thread,
                                                        key.cString(using: .utf8))) {
            defer {
                _ = try? ErrorCheck.nativeCall(thread, dxfg_system_release_property(thread, property))
            }
            return String(pointee: property)
        }
        return nil
    }
}
