//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

/// Type of an iceberg order.
public enum IcebergType: Int, CaseIterable {
    /// Iceberg type is undefined, unknown or inapplicable.
    case undefined = 0
    /// Represents native (exchange-managed) iceberg type.
    case native
    /// Represents synthetic (managed outside of the exchange) iceberg type.
    case synthetic
}

/// Class extension for  ``IcebergType`` enum.
public class IcebergTypeExt {
    private static let values: [IcebergType] =
    EnumUtil.createEnumBitMaskArrayByValue(defaultValue: .undefined, allCases: IcebergType.allCases)

    /// Returns an enum constant of the``IcebergType`` by integer code bit pattern.
    /// - Parameters:
    ///   - value: Property value
    /// - Returns: The enum constant of the specified enum type with the specified value
    public static func valueOf(value: Int) -> IcebergType {
        return values[value]
    }
}
