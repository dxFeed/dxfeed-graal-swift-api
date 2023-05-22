//
//  NativeProperty.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 21.03.2023.
//

import Foundation
@_implementationOnly import graal_api

class NativeProperty {
    static func test() throws {
        try ErrorCheck.test()
    }

    static func setProperty(_ key: String, _ value: String) throws {
        let thread =  currentThread()
        try ErrorCheck.nativeCall(thread,
                                  dxfg_system_set_property(thread,
                                                           key.cString(using: .utf8),
                                                           value.cString(using: .utf8))
        )
    }

    static func getProperty(_ key: String) -> String? {
        let property = dxfg_system_get_property(ThreadManager.shared.attachThread().threadPointer.pointee,
                                                key.cString(using: .utf8))
        if let property = property {
            let result = String(utf8String: property)
            dxfg_system_release_property(ThreadManager.shared.attachThread().threadPointer.pointee, property)
            return result
        } else {
            return nil
        }
    }
}
