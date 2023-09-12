//
//  CandlePeriod.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 14.07.23.
//

import Foundation

/// Period attribute of ``CandleSymbol`` defines aggregation period of the candles.
/// Aggregation period is defined as pair of a ``value`` and ``type``.
///
/// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/candle/CandlePeriod.html)
public class CandlePeriod {
    /// The attribute key that is used to store the value of ``CandlePeriod`` in
    /// a symbol string using methods of ``MarketEventSymbols`` class.
    /// The value of this constant is an empty string, because this is the
    /// main attribute that every ``CandleSymbol`` must have.
    /// The value that this key shall be set to is equal to
    /// the corresponding ``toString()``.
    public static let attributeKey = "" // Empty string as attribute key is allowed!
    /// The number represents default period value.
    private static let defaultPeriodValue: Double = 1
    /// Tick aggregation where each candle represents an individual tick.
    public static let tick = CandlePeriod(value: defaultPeriodValue, type: CandleType.tick)
    /// Day aggregation where each candle represents a day.
    public static let day = CandlePeriod(value: defaultPeriodValue, type: CandleType.day)
    /// Default period is ``tick``.
    public static let defaultPeriod = tick
    /// Gets aggregation period value.
    /// For example, the value of 5 with
    /// the candle type of ``CandleType/minute`` represents 5 minute
    /// aggregation period.
    public let value: Double
    /// Gets aggregation period type.
    public let type: CandleType
    public let periodIntervalMillis: Long
    /// The cached value of the string representation of this candle period.
    lazy var stringRepresentation: String = {
        if value == CandlePeriod.defaultPeriodValue {
            return type.toString()
        }
        return Double(Long(value)) == value ? "\(Long(value))\(type.toString())" : "\(value)\(type.toString())"
    }()
    /// Normalizes candle symbol string with representation of the candle period attribute.
    ///
    /// - Parameters:
    ///   - symbol: The candle symbol string.
    /// - Returns: Returns candle symbol string with the normalized representation of the candle period attribute.
    static func normalizeAttributeForSymbol(_ symbol: String?) -> String? {
        let attribute = try? MarketEventSymbols.getAttributeStringByKey(symbol, attributeKey)
        guard let value = attribute else {
            return symbol
        }
        do {
            let other = try parse(value)
            if other == defaultPeriod {
                _ = MarketEventSymbols.removeAttributeStringByKey(symbol, attributeKey)
            }
            if attribute != other.toString() {
                return try MarketEventSymbols.changeAttributeStringByKey(symbol,
                                                                         attribute,
                                                                         other.toString())
            }
        } catch let error {
            print(error)
        }
        return symbol
    }

    /// Gets candle period of the given candle symbol string.
    ///
    /// The result is ``defaultPeriod`` if the symbol does not have candle period attribute.
    ///
    /// -  Parameters:
    ///    - symbol: The candle symbol string.
    /// - Returns: The candle period of the given candle symbol string.
    /// - Throws: ``ArgumentException/argumentNil``
    static func getAttribute(_ symbol: String?) throws -> CandlePeriod {
        let attribute = try MarketEventSymbols.getAttributeStringByKey(symbol, attributeKey)
        guard let attribute = attribute else {
            return defaultPeriod
        }
        return try parse(attribute)
    }

    /// Parses string representation of candle period type into object.
    /// Any string that was returned by ``toString()`` can be parsed
    /// and case is ignored for parsing.
    ///
    /// -  Parameters:
    ///    - symbol: The string representation of candle period
    /// - Returns: The candle period.
    /// - Throws: ``ArgumentException/missingCandleType``
    static func parse(_ symbol: String) throws -> CandlePeriod {
        if symbol == CandleType.day.toString() {
            return day
        } else if symbol == CandleType.tick.toString() {
            return tick
        }
        var index = 0
        for jindex in 0..<symbol.length {
            let charset = CharacterSet(charactersIn: "0123456789+-.eE")
            let char = symbol[jindex]
            if char.rangeOfCharacter(from: charset) == nil {
                index = jindex
                break
            }
        }
        let value = symbol[0..<index]
        let type = symbol[index..<symbol.length]

        return valueOf(value: value.isEmpty ? 1 : Double(value)!, type: try CandleType.parse(type))

    }
    /// Converts the given string symbol into the candle period object.
    public static func valueOf(value: Double, type: CandleType) -> CandlePeriod {
        if value == defaultPeriodValue {
            if type == CandleType.day {
                return day
            } else if type == .tick {
                return tick
            }
        }
        return CandlePeriod(value: value, type: type)
    }

    private init(value: Double, type: CandleType) {
        self.value = value
        self.type = type
        self.periodIntervalMillis = type.rawValue.periodIntervalMillis * Long(value)
    }
    /// Returns string representation of this candle period.
    ///
    /// - Returns: The string representation.
    public func toString() -> String {
        return stringRepresentation
    }
}

extension CandlePeriod: Equatable {
    public static func == (lhs: CandlePeriod, rhs: CandlePeriod) -> Bool {
        return lhs === rhs || (lhs.value == rhs.value && lhs.type == rhs.type)
    }
}

extension CandlePeriod: ICandleSymbolProperty {
    /// Change candle event symbol string with this attribute set
    /// and returns new candle event symbol string.
    public func changeAttributeForSymbol(symbol: String?) -> String? {
        if self === CandlePeriod.defaultPeriod {
            return MarketEventSymbols.removeAttributeStringByKey(symbol, CandlePeriod.attributeKey)
        } else {
            return try? MarketEventSymbols.changeAttributeStringByKey(symbol, CandlePeriod.attributeKey, toString())
        }
    }
    /// Internal method that initializes attribute in the candle symbol.
    public func checkInAttribute(candleSymbol: CandleSymbol) throws {
        if candleSymbol.period != nil {
            throw ArgumentException.invalidOperationException("already initialized")
        }
        candleSymbol.period = self
    }
}
