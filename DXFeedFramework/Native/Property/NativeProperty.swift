//
//  NativeProperty.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 21.03.2023.
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
        let property = dxfg_system_get_property(thread,
                                                key.cString(using: .utf8))
        if let property = property {
            let result = String(utf8String: property)
            dxfg_system_release_property(thread, property)
            return result
        } else {
            return nil
        }
    }
}
