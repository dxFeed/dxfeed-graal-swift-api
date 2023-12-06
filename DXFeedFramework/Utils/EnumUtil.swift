//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
