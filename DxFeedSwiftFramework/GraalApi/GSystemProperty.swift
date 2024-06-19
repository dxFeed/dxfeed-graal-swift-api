//
//  GSystemProperty.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 16.03.2023.
//

import Foundation
@_implementationOnly import graal_api

class GSystemProperty {
    static func setProperty(_ key: String, _ value: String) -> GStatusCode {
        return  GNativeExecutor.execute {
            dxfg_system_set_property(GraalThreadManager.shared.attachThread().thread.pointee, key.toCStringRef(), value.toCStringRef());
        }
    }
    
    static func getProperty(_ key: String) -> String? {
        let property = dxfg_system_get_property(GraalThreadManager.shared.attachThread().thread.pointee, key.cString(using: String.Encoding.utf8))
        if let property = property {
            let result = String(utf8String: property)
            dxfg_system_release_property(GraalThreadManager.shared.attachThread().thread.pointee, property);
            return result
        } else {
            return nil
        }
    }
}
