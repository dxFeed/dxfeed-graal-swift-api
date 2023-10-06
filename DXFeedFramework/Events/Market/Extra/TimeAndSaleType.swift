//
//  TimeAndSaleType.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 22.08.23.
//

import Foundation
/// Type of a time and sale event.
///
/// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/market/TimeAndSaleType.html)
public enum TimeAndSaleType: Int, CaseIterable {
    /// Represents new time and sale event.
    case new = 0
    /// Represents correction time and sale event.
    case correction
    /// Represents cancel time and sale event.
    case cancel

    static let values: [TimeAndSaleType] = {
        EnumUtil.createEnumBitMaskArrayByValue(defaultValue: .new, allCases: TimeAndSaleType.allCases)
    }()
    /// Returns an enum constant of the ``TimeAndSaleType`` by integer code bit pattern.
    public static func valueOf(_ value: Int) -> TimeAndSaleType {
        return TimeAndSaleType.values[value]
    }
}
