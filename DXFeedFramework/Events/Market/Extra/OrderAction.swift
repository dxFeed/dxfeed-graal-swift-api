//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

public enum OrderAction: Int, CaseIterable {
    /// Default enum value for orders that do not support "Full Order Book" and for backward compatibility -
    /// action must be derived from other ``Order``
    case undefined = 0
    /// New Order is added to Order Book.
    case new
    /// Order is modified and price-time-priority is not maintained (i.e. order has re-entered Order Book).
    case replace
    /// Order is modified without changing its price-time-priority (usually due to partial cancel by user).
    case modify
    /// Order is fully canceled and removed from Order Book.
    case delete
    /// Size is changed (usually reduced) due to partial order execution.
    case partial
    /// Order is fully executed and removed from Order Book.
    case execute
    /// Non-Book Trade - this Trade not refers to any entry in Order Book.
    case trade
    /// Prior Trade/Order Execution bust
    case bust
}

internal class OrderActionExt {
    private static let values: [OrderAction] =
    EnumUtil.createEnumBitMaskArrayByValue(defaultValue: .undefined, allCases: OrderAction.allCases)

    public static func valueOf(value: Int) -> OrderAction {
        return values[value]
    }
}
