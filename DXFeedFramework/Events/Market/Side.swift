//
//  Side.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 22.08.23.
//

import Foundation
/// Side of an order or a trade.
///
/// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/market/Side.html)
public enum Side: Int, CaseIterable {
    /// Side is undefined, unknown or inapplicable.
    case undefined = 0
    /// Buy side (bid).
    case buy
    /// Sell side (ask or offer).
    case sell

    static let values: [Side] = {
        EnumUtil.createEnumBitMaskArrayByValue(defaultValue: .undefined, allCases: Side.allCases)
    }()
    /// Returns an enum constant of the ``Side`` by integer code bit pattern.
    public static func valueOf(_ value: Int) -> Side {
        return Side.values[value]
    }
}
