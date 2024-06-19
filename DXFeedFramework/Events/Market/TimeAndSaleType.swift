//
//  TimeAndSaleType.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 22.08.23.
//

import Foundation

public enum TimeAndSaleType: Int, CaseIterable {
    case new = 0
    case correction
    case cancel

    static let values: [TimeAndSaleType] = {
        EnumUtil.createEnumBitMaskArrayByValue(defaultValue: .new, allCases: TimeAndSaleType.allCases)
    }()

    static func valueOf(_ value: Int) -> TimeAndSaleType {
        return TimeAndSaleType.values[value]
    }
}
