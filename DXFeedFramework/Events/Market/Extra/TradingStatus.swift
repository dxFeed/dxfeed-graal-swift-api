//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

/// Trading status of an instrument.
public enum TradingStatus: Int, CaseIterable {
    /// Trading status is undefined, unknown or inapplicable.
    case undefined = 0
    /// Trading is halted.
    case halted
    /// Trading is active.
    case active

    static let values: [TradingStatus] = {
        EnumUtil.createEnumBitMaskArrayByValue(defaultValue: .undefined, allCases: TradingStatus.allCases)
    }()

    /// Returns an enum constant of the ``TradingStatus`` by integer code bit pattern.
    public static func valueOf(_ value: Int) -> TradingStatus {
        return TradingStatus.values[value]
    }
}
