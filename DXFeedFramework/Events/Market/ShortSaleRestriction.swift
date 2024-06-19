//
//  ShortSaleRestriction.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 22.08.23.
//

import Foundation

/// Short sale restriction on an instrument.
public enum ShortSaleRestriction: Int, CaseIterable {
    /// Short sale restriction is undefined, unknown or inapplicable.
    case undefined = 0
    /// Short sale restriction is active.
    case active
    /// Short sale restriction is inactive.
    case inactive

    static let values: [ShortSaleRestriction] = {
        EnumUtil.createEnumBitMaskArrayByValue(defaultValue: .undefined, allCases: ShortSaleRestriction.allCases)
    }()

    /// Returns an enum constant of the ``ShortSaleRestriction`` by integer code bit pattern.
    public static func valueOf(_ value: Int) -> ShortSaleRestriction {
        return ShortSaleRestriction.values[value]
    }
}
