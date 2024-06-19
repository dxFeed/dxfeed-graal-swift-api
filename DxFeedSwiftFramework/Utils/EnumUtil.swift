//
//  EnumUtils.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 22.05.23.
//

import Foundation

class EnumUtil {
    static func valueOf<T: Any>(value: T?) throws -> T {
        if let value = value {
            return value
        }
        throw EnumException.undefinedEnumValue
    }
}
