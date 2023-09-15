//
//  CandleType.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 14.07.23.
//

import Foundation

/// This ``DXCandleType`` structure is created to circumvent the limitation that enums in Swift cannot contain stored properties.
/// The "Enums must not contain stored properties" error occurs when attempting to add a stored property to an enum. Instead, we use this structure to store data that we would like to include in the enum.
public struct DXCandleType: Equatable {
    /// Gets full name this ``CandleType`` instance.
    public let name: String
    /// Get string value of type
    public let value: String
    /// Gets candle type period in milliseconds (aggregation period) as closely as possible.
    /// Certain types like ``CandleType/second`` and
    /// ``CandleType/day`` span a specific number of milliseconds.
    /// ``CandleType/month``, ``CandleType/optExp`` and ``CandleType/year``
    /// are approximate. Candle type period of
    /// ``CandleType/tick``, ``CandleType/volume``, ``CandleType/price``,
    /// ``CandleType/priceMomentum`` and ``CandleType/priceRenko``
    /// is not defined and this method returns 0
    public let periodIntervalMillis: Long
}
/// Type of the candle aggregation period constitutes ``CandlePeriod`` type together
/// its actual ``CandlePeriod.Value``.
/// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/candle/CandleType.html)
extension DXCandleType: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        value = stringLiteral
        switch stringLiteral {
        case "t":
            name = "Tick"
            periodIntervalMillis = 0
        case "s":
            name = "Second"
            periodIntervalMillis = 1000
        case "m":
            name = "Minute"
            periodIntervalMillis = 60 * 1000
        case "h":
            name = "Hour"
            periodIntervalMillis = 60 * 60 * 1000
        case "d":
            name = "Day"
            periodIntervalMillis = 24 * 60 * 60 * 1000
        case "w":
            name = "Week"
            periodIntervalMillis = 7 * 24 * 60 * 60 * 1000
        case "mo":
            name = "Month"
            periodIntervalMillis = 30 * 24 * 60 * 60 * 1000
        case "o":
            name = "OptExp"
            periodIntervalMillis = 30 * 24 * 60 * 60 * 1000
        case "y":
            name = "Year"
            periodIntervalMillis = 365 * 24 * 60 * 60 * 1000
        case "v":
            name = "Volume"
            periodIntervalMillis = 0
        case "p":
            name = "Price"
            periodIntervalMillis = 0
        case "pm":
            name = "PriceMomentum"
            periodIntervalMillis = 0
        case "pr":
            name = "PriceRenko"
            periodIntervalMillis = 0
        default:
            name = "Tick"
            periodIntervalMillis = 0
        }
    }
}

public enum CandleType: DXCandleType, CaseIterable {
    /// Certain number of ticks.
    case tick =             "t"
    /// Certain number of seconds.
    case second =           "s"
    /// Certain number of minutes.
    case minute =           "m"
    /// Certain number of hours.
    case hour =             "h"
    /// Certain number of days.
    case day =              "d"
    /// Certain number of weeks.
    case week =             "w"
    /// Certain number of months.
    case month =            "mo"
    /// Certain number of option expirations.
    case optExp =           "o"
    /// Certain number of years.
    case year =             "y"
    /// Certain volume of trades.
    case volume =           "v"
    /// Certain price change, calculated according to the following rules:
    ///
    ///     high(n) - low(n) = price range
    ///     close(n) = high(n) or close(n) = low(n)
    ///     open(n+1) = close(n)
    ///
    /// where n is the number of the bar.
    case price =            "p"
    /// Certain price change, calculated according to the following rules:
    ///
    ///     high(n) - low(n) = price range
    ///     close(n) = high(n) or close(n) = low(n)
    ///     open(n+1) = close(n) + tick size, if close(n) = high(n)
    ///     open(n+1) = close(n) - tick size, if close(n) = low(n)
    ///
    /// where n is the number of the bar.
    case priceMomentum =    "pm"
    /// Certain price change, calculated according to the following rules:
    ///
    ///     high(n+1) - high(n) = price range or low(n) - low(n+1) = price range
    ///     close(n) = high(n) or close(n) = low(n)
    ///     open(n+1) = high(n), if high(n+1) - high(n) = price range
    ///     open(n+1) = low(n), if low(n) - low(n+1) = price range
    ///
    /// where n is the number of the bar.
    case priceRenko =       "pr"

    /// A dictionary containing the matching string representation
    /// of the candle alignment attribute ``DXCandleType/value`` and the ``CandleType`` instance.
    static let byString = {
        let myDict = Self.allCases.reduce(into: [String: CandleType]()) {
            $0[$1.toString()] = $1
        }
        return myDict
    }()

    /// Parses string representation of candle type into object.
    /// Any string that is a prefix of candle type ``DXCandleType/name`` can be parsed
    /// (including the one that was returned by ``DXCandleType/value``
    /// and case is ignored for parsing.
    ///
    /// -  Parameters:
    ///    - symbol: The string representation of candle type
    /// - Returns: The candle type.
    /// - Throws: ``ArgumentException/missingCandleType``
    public static func parse(_ symbol: String) throws -> CandleType {
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
    /// Returns string representation of this candle type.
    ///
    /// The string representation of candle type is the shortest unique prefix of the
    /// lower case string that corresponds to its ``DXCandleType/name`` For example,
    /// ``tick`` is represented as "t", while ``month`` is represented as
    /// "mo" to distinguish it from ``minute`` that is represented as "m".
    /// - Returns: The string representation.
    public func toString() -> String {
        return self.rawValue.value
    }
}
