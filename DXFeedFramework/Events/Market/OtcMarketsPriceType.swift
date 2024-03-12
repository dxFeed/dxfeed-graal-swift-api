//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

/// This ``DXOtcMarketsPriceType`` structure is created to circumvent the limitation that enums in Swift cannot contain stored properties.
/// The "Enums must not contain stored properties" error occurs when attempting to add a stored property to an enum. Instead, we use this structure to store data that we would like to include in the enum.
public struct DXOtcMarketsPriceType: Equatable {
    public let name: String
    /// Get string value of type
    public let code: Int
}

extension DXOtcMarketsPriceType: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        switch value {
        case 0:
            name = "UNPRICED"
            code = value
        case 1:
            name = "ACTUAL"
            code = value
        case 2:
            name = "WANTED"
            code = value
        default:
            fatalError("Try to initialize PriceType with wrong value \(value)")
        }
    }
}

/// Type of prices on the OTC Markets.
public enum OtcMarketsPriceType: DXOtcMarketsPriceType, CaseIterable {
    /// Unpriced quotes are an indication of interest (IOI) in a security
    /// used when a trader does not wish to show a price or size.
    /// Unpriced, name-only quotes are also used as the other side of a one-sided, priced quote.
    /// Unpriced quotes may not have a Quote Access Payment (QAP) value.
    case unpriced = 0
    /// Actual (Priced) is the actual amount a trader is willing to buy or sell securities.
    case actual = 1
    /// Offer Wanted/Bid Wanted (OW/BW) is used to solicit sellers/buyers,
    /// without displaying actual price or size.
    /// OW/BW quotes may not have a Quote Access Payment (QAP) value.
    case wanted = 2

    internal static let types: [OtcMarketsPriceType] = {
        EnumUtil.createEnumBitMaskArrayByValue(defaultValue: .unpriced,
                                               allCases: OtcMarketsPriceType.allCases)
    }()

    /// Returns price type by integer code bit pattern.
    public static func valueOf(_ value: Int) -> OtcMarketsPriceType {
        return OtcMarketsPriceType.types[value]
    }
}
