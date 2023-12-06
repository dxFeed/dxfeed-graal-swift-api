//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
