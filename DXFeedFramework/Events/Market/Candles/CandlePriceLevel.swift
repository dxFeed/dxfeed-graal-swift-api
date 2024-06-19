//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

/// Candle price level attribute of ``CandleSymbol`` defines how candles shall be aggregated in respect to
/// price interval. The negative or infinite values of price interval are treated as exceptional.
///
/// Price interval may be equal to zero. It means every unique price creates a particular candle
/// to aggregate all events with this price for the chosen ``CandlePeriod``
/// Non-zero price level creates sequence of intervals starting from 0:
/// ...,[-pl;0),[0;pl),[pl;2*pl),...,[n*pl,n*pl+pl).
/// Events aggregated by chosen ``CandlePeriod`` and price intervals.
///
/// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/candle/CandlePriceLevel.html)
public class CandlePriceLevel {
    /// The attribute key that is used to store the value of ``CandlePriceLevel`` in
    /// a symbol string using methods of ``MarketEventSymbols`` class.
    /// The value of this constant is "pl".
    /// The value that this key shall be set to is equal to
    /// the corresponding ``toString()``.
    public static let attributeKey = "pl"

    /// Gets a price level value.
    ///
    /// For example, the value of 1 represents [0;1), [1;2) and so on intervals to build candles.
    public let value: Double
    /// Default candle price level Double.nan
    public static let defaultCandlePriceLevel = try? CandlePriceLevel(value: Double.nan)

    lazy var stringDescription: String = {
        return Double(Long(value)) == value ? "\(Long(value))" : "\(value)"
    }()

    private init(value: Double) throws {
        if value.isInfinite || value == -0.0 {
            throw ArgumentException.incorrectCandlePrice
        }
        self.value = value
    }

    /// Normalizes candle symbol string with representation of the candle price level attribute.
    ///
    /// - Parameters:
    ///   - symbol: The candle symbol string.
    /// - Returns: Returns candle symbol string with the normalized representation of the candle price level attribute.
    public static func normalizeAttributeForSymbol(_ symbol: String?) -> String? {
        let attribute = try? MarketEventSymbols.getAttributeStringByKey(symbol, attributeKey)
        guard let attribute = attribute else {
            return symbol
        }
        do {
            let other = try parse(attribute)
            if other === defaultCandlePriceLevel {
                _ = MarketEventSymbols.removeAttributeStringByKey(symbol, attributeKey)
            }
            if attribute != other.toString() {
                return try MarketEventSymbols.changeAttributeStringByKey(symbol,
                                                                         attributeKey,
                                                                         other.toString())
            }
        } catch let error {
            print(error)
        }
        return symbol
    }

    /// Returns candle price level object that corresponds to the specified value.
    ///
    /// - Parameters:
    ///   - value: The candle price level value.
    /// - Returns: The candle price level with the given value and type.
    /// - Throws: ``ArgumentException/incorrectCandlePrice``
    public static func valueOf(value: Double) throws -> CandlePriceLevel {
        value.isNaN ? defaultCandlePriceLevel! : try CandlePriceLevel(value: value)
    }

    /// Parses string representation of candle price level into object.
    /// Any string that was returned by ``toString()`` can be parsed
    /// and case is ignored for parsing.
    ///
    /// -  Parameters:
    ///    - symbol: The string representation of candle price level
    /// - Returns: The candle price level.
    /// - Throws: ``ArgumentException/unknowCandlePriceLevel``
    public static func parse(_ symbol: String) throws -> CandlePriceLevel {
        if let value = Double(symbol) {
            return try valueOf(value: value)
        }
        throw ArgumentException.unknowCandlePriceLevel
    }

    /// Gets candle price level of the given candle symbol string.
    ///
    /// The result is ``defaultCandlePriceLevel`` if the symbol does not have candle price level attribute.
    ///
    /// -  Parameters:
    ///    - symbol: The candle symbol string.
    /// - Returns: The candle price levlel of the given candle symbol string.
    /// - Throws: ``ArgumentException/argumentNil``, ``ArgumentException/unknowCandlePriceLevel``
    public static func getAttribute(_ symbol: String?) throws -> CandlePriceLevel {
        let attribute = try MarketEventSymbols.getAttributeStringByKey(symbol, attributeKey)
        guard let attribute = attribute else {
            return defaultCandlePriceLevel!
        }
        return try parse(attribute)
    }

    /// Returns string representation of this candle price level attribute.
    /// The string representation is composed of value.
    /// This string representation can be converted back into object
    /// with ``parse(_:)`` method.
    public func toString() -> String {
        return stringDescription
    }

    /// Returns full string representation of this candle price level attribute.
    ///
    /// It is contains attribute key and its value.
    /// For example, the  full string representation of price level = 0.5 is "pl=0.5".
    /// - Returns: The full string representation of a candle price level attribute
    func toFullString() -> String {
        return "\(CandlePriceLevel.attributeKey)=\(toString())"
    }
}

extension CandlePriceLevel: Equatable {
    public static func == (lhs: CandlePriceLevel, rhs: CandlePriceLevel) -> Bool {
        return lhs === rhs || (lhs.value ~== rhs.value)
    }
}

extension CandlePriceLevel: ICandleSymbolProperty {
    public func changeAttributeForSymbol(symbol: String?) -> String? {
        self == CandlePriceLevel.defaultCandlePriceLevel ?
        MarketEventSymbols.removeAttributeStringByKey(symbol, CandlePriceLevel.attributeKey) :
        try? MarketEventSymbols.changeAttributeStringByKey(symbol, CandlePriceLevel.attributeKey, toString())
    }

    public func checkInAttribute(candleSymbol: CandleSymbol) throws {
        if candleSymbol.priceLevel != nil {
            throw ArgumentException.invalidOperationException("Already initialized")
        }
        candleSymbol.priceLevel = self
    }
}
