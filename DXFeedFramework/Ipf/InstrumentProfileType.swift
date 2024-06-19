//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

/// Defines standard types of ``InstrumentProfile``.
///
/// Note that other (unknown) types
/// can be used without listing in this class - use it for convenience only.
/// Please see Instrument Profile Format documentation for complete description.
public enum InstrumentProfileType: String, CaseIterable {
    case currency = "CURRENCY"
    case forex = "FOREX"
    case bond = "BOND"
    case index = "INDEX"
    case stock = "STOCK"
    case etf = "ETF"
    case mutualFund = "MUTUAL_FUND"
    case moneyMarketFund = "MONEY_MARKET_FUND"
    case product = "PRODUCT"
    case future = "FUTURE"
    case option = "OPTION"
    case warrant = "WARRANT"
    case cfd = "CFD"
    case spread = "SPREAD"
    case other = "OTHER"
    case removed = "REMOVED"

    static let byString = {
        let myDict = Self.allCases.reduce(into: [String: InstrumentProfileType]()) {
            $0[$1.rawValue] = $1
        }
        return myDict
    }()

    /// Returns field for specified name or null if field is not found.
    public static func find(_ name: String) -> Self? {
        guard let value = byString[name] else {
            return nil
        }
        return value
    }
}

public extension InstrumentProfile {
    func getIpfType() -> InstrumentProfileType? {
        return InstrumentProfileType.find(self.type)
    }
}
