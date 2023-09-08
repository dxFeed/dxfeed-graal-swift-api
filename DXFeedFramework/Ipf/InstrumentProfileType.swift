//
//  InstrumentProfileType.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 08.09.23.
//

import Foundation

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

    public static func find(_ name: String) throws -> Self {
        guard let value = byString[name] else {
            throw ArgumentException.unknowValue(name, byString.keys.joined(separator: ","))
        }
        return value
    }
}
