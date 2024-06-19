//
//  EnumUtils.swift
//  DXFeedFramework
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

    static func createEnumBitMaskArrayByValue<T>(defaultValue: T, allCases: [T]) -> [T] {
        let allvalues = allCases
        let length = allvalues.count.roundedUp(toMultipleOf: 2)
        var result = [T]()
        for index in 0..<length {
            if index >= allvalues.count {
                result.append(defaultValue)
            } else {
                result.append(allvalues[index])
            }
        }
        return result
    }
}
