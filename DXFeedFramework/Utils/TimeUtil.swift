//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

public class TimeUtil {
    static let second =  Long(1000)
    static let minute =  60 * second
    static let hour = 60 * minute
    static let day = 24 * hour

    static let dateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return formatter
    }()
    static let dateFormatterWithMillis = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss.SSSZZZZZ"
        return formatter
    }()

    public static func getMillisFromTime(_ timeMillis: Long) -> Int {
        return Int(MathUtil.floorMod(timeMillis, second))
    }

    public static func getSecondsFromTime(_ timeMillis: Long) -> Int {
        if timeMillis >= 0 {
            return min(Int(timeMillis / second), Int.max)
        } else {
            return max(Int((timeMillis + 1) / second) - 1, Int.min)
        }
    }
}
