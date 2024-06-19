//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
