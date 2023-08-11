//
//  CandleType.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 14.07.23.
//

import Foundation

public struct DXCandleType: Equatable {
    public let name: String
    public let value: String
    public let periodIntervalMillis: Long
}

extension DXCandleType: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        switch stringLiteral {
        case "t":
            value = stringLiteral
            name = "Tick"
            periodIntervalMillis = 0
        case "s":
            value = stringLiteral
            name = "Second"
            periodIntervalMillis = 1000
        case "m":
            value = stringLiteral
            name = "Minute"
            periodIntervalMillis = 60 * 1000
        case "h":
            value = stringLiteral
            name = "Hour"
            periodIntervalMillis = 60 * 60 * 1000
        case "d":
            value = stringLiteral
            name = "Day"
            periodIntervalMillis = 24 * 60 * 60 * 1000
        case "w":
            value = stringLiteral
            name = "Week"
            periodIntervalMillis = 7 * 24 * 60 * 60 * 1000
        case "mo":
            value = stringLiteral
            name = "Month"
            periodIntervalMillis = 30 * 24 * 60 * 60 * 1000
        case "o":
            value = stringLiteral
            name = "OptExp"
            periodIntervalMillis = 30 * 24 * 60 * 60 * 1000
        case "y":
            value = stringLiteral
            name = "Year"
            periodIntervalMillis = 365 * 24 * 60 * 60 * 1000
        case "v":
            value = stringLiteral
            name = "Volume"
            periodIntervalMillis = 0
        case "p":
            value = stringLiteral
            name = "Price"
            periodIntervalMillis = 0
        case "pm":
            value = stringLiteral
            name = "PriceMomentum"
            periodIntervalMillis = 0
        case "pr":
            value = stringLiteral
            name = "PriceRenko"
            periodIntervalMillis = 0
        default:
            value = stringLiteral
            name = "Tick"
            periodIntervalMillis = 0
        }
    }
}

enum CandleType: DXCandleType, CaseIterable {
    case tick =             "t"
    case second =           "s"
    case minute =           "m"
    case hour =             "h"
    case day =              "d"
    case week =             "w"
    case month =            "mo"
    case optExp =           "o"
    case year =             "y"
    case volume =           "v"
    case price =            "p"
    case priceMomentum =    "pm"
    case priceRenko =       "pr"

    static let byString = {
        let myDict = Self.allCases.reduce(into: [String: CandleType]()) {
            $0[$1.toString()] = $1
        }
        return myDict
    }()

    static func parse(_ symbol: String) throws -> CandleType {
        let length = symbol.length
        if length == 0 {
            throw ArgumentException.missingCandleType
        }
        // Fast path to reverse toString result
        if let fValue = byString[symbol] {
            return fValue
        }
        // Slow path for different case.
        let sValue = CandleType.allCases.first(where: { type in
            let name = type.rawValue.name
            if name.length >= length && name[0..<length].equalsIgnoreCase(symbol) {
                return true
            }
            if symbol.hasSuffix("s") && name.equalsIgnoreCase(symbol[0..<length-1]) {
                return true
            }
            return false
        })
        guard let sValue = sValue else {
            throw ArgumentException.unknowCandleType
        }
        return sValue
    }

    func toString() -> String {
        return self.rawValue.value
    }
}
