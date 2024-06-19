//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
/// Direction of the price movement. For example tick direction for last trade price.
///
/// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/market/Direction.html)
public enum Direction: Int32, CaseIterable {
    // swiftlint:disable identifier_name
    /// Direction is undefined, unknown or inapplicable.
    /// It includes cases with undefined price value or when direction computation was not performed.
    case undefined = 0
    /// Current price is lower than previous price.
    case down
    /// Current price is the same as previous price and is lower than the last known price of different value.
    case zeroDown
    /// Current price is equal to the only known price value suitable for price direction computation.
    /// Unlike ``undefined`` the ``zero`` direction implies that current price is defined and
    /// direction computation was duly performed but has failed to detect any upward or downward price movement.
    /// It is also reported for cases when price sequence was broken and direction computation was restarted anew.
    case zero
    /// Current price is the same as previous price and is higher than the last known price of different value.
    case zeroUp
    /// Current price is higher than previous price.
    case up
    // swiftlint:enable identifier_name

    static let values: [Direction] = {
        EnumUtil.createEnumBitMaskArrayByValue(defaultValue: .undefined, allCases: Direction.allCases)
    }()

    /// Returns an enum constant of the ``Direction`` by integer code bit pattern.
    public static func valueOf(_ value: Int) -> Direction {
        return Direction.values[value]
    }
}
