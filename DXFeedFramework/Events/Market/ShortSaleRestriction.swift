//
//  ShortSaleRestriction.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 22.08.23.
//

import Foundation

public enum ShortSaleRestriction: Int, CaseIterable {
    case undefined = 0
    case active
    case inactive

    static let values: [ShortSaleRestriction] = {
        EnumUtil.createEnumBitMaskArrayByValue(defaultValue: .undefined, allCases: ShortSaleRestriction.allCases)
    }()

    static func valueOf(_ value: Int) -> ShortSaleRestriction {
        return ShortSaleRestriction.values[value]
    }
}
