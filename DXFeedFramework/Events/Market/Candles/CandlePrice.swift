//
//  CandlePrice.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 14.07.23.
//

import Foundation
/// This ``DXCandlePrice`` structure is created to circumvent the limitation that enums in Swift cannot contain stored properties.
/// 
/// The "Enums must not contain stored properties" error occurs when attempting to add a stored property to an enum. Instead, we use this structure to store data that we would like to include in the enum.
public struct DXCandlePrice: Equatable {
    /// Gets full name this ``CandlePrice`` instance.
    /// For example,
    /// ``CandlePrice/last`` returns "Last",
    /// ``CandlePrice/bid`` returns "Bid".
    public let name: String
    /// Get string value of type
    public let string: String
}

extension DXCandlePrice: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        switch stringLiteral {
        case "last":
            string = stringLiteral
            name = "Last"
        case "bid":
            string = stringLiteral
            name = "Bid"
        case "ask":
            string = stringLiteral
            name = "Ask"
        case "mark":
            string = stringLiteral
            name = "Mark"
        case "s":
            string = stringLiteral
            name = "Settlement"
        default:
            string = stringLiteral
            name = "Last"
        }
    }
}

/// Price type attribute of ``CandleSymbol`` defines price that is used to build the candles.
///
/// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/candle/CandlePrice.html)
public enum CandlePrice: DXCandlePrice, CaseIterable {
    /// Last trading price.
    case last = "last"
    /// Quote bid price.
    case bid = "bid"
    /// Quote ask price.
    case ask = "ask"
    /// Market price defined as average between quote bid and ask prices.
    case mark = "mark"
    /// Official settlement price that is defined by exchange or last trading price otherwise.
    /// It updates based on all ``CandlePrice``values.
    case settlement = "s"
    /// The attribute key that is used to store the value of ``CandlePrice`` in
    /// a symbol string using methods of ``MarketEventSymbols`` class.
    ///
    /// The value of this constant is "price".
    /// The value that this key shall be set to is equal to
    /// the corresponding ``toString()``
    public static let attributeKey = "price"

    public static let defaultPrice = last

    /// A dictionary containing the matching string representation
    /// of the candle price type attribute ``toString()`` and the ``CandlePrice`` instance.
    static let byString = {
        let myDict = Self.allCases.reduce(into: [String: CandlePrice]()) {
            $0[$1.toString()] = $1
        }
        return myDict
    }()
    /// Normalizes candle symbol string with representation of the candle price attribute.
    ///
    /// - Parameters:
    ///   - symbol: The candle symbol string.
    /// - Returns: Returns candle symbol string with the normalized representation of the candle price attribute.
    public static func normalizeAttributeForSymbol(_ symbol: String?) -> String? {
        let attribute = try? MarketEventSymbols.getAttributeStringByKey(symbol, attributeKey)
        guard let value = attribute else {
            return symbol
        }
        do {
            let other = try parse(value)
            if other == defaultPrice {
                _ = MarketEventSymbols.removeAttributeStringByKey(symbol, attributeKey)
            }
            if attribute != other.toString() {
                return try MarketEventSymbols.changeAttributeStringByKey(symbol, attributeKey, other.toString())
            }
        } catch let error {
            print(error)
        }
        return symbol
    }
    /// Gets candle price of the given candle symbol string.
    ///
    /// The result is ``defaultPrice`` if the symbol does not have candle price attribute.
    ///
    /// -  Parameters:
    ///    - symbol: The candle symbol string.
    /// - Returns: The candle price of the given candle symbol string.
    /// - Throws: ``ArgumentException/missingCandlePrice``, ``ArgumentException/unknowCandlePrice``
    public static func getAttribute(_ symbol: String?) throws -> CandlePrice {
        let attribute = try MarketEventSymbols.getAttributeStringByKey(symbol, attributeKey)
        guard let value = attribute else {
            return defaultPrice
        }
        return try parse(value)
    }

    /// Parses string representation of candle price type into object.
    /// Any string that was returned by ``toString()`` can be parsed
    /// and case is ignored for parsing.
    ///
    /// -  Parameters:
    ///    - symbol: The string representation of candle price
    /// - Returns: The candle price.
    /// - Throws: ``ArgumentException/missingCandlePrice``, ``ArgumentException/unknowCandlePrice``
    public static func parse(_ symbol: String) throws -> CandlePrice {
        let length = symbol.length
        if length == 0 {
            throw ArgumentException.missingCandlePrice
        }
        // Fast path to reverse toString result.
        if let fvalue = byString[symbol] {
            return fvalue
        }
        // Slow path for different case.
        let sValue = CandlePrice.allCases.first( where: { price in
            let pString = price.toString()
            return pString.length >= length && pString[0..<length].equalsIgnoreCase(symbol)
        })
        guard let sValue = sValue else {
            throw ArgumentException.unknowCandlePrice
        }
        return sValue
    }
    /// Returns string representation of this candle price.
    ///
    /// - Returns: The string representation.
    public func toString() -> String {
        return self.rawValue.string
    }
}

extension CandlePrice: ICandleSymbolProperty {
    /// Change candle event symbol string with this attribute set
    /// and returns new candle event symbol string.
    public func changeAttributeForSymbol(symbol: String?) -> String? {
        self == CandlePrice.defaultPrice ?
        MarketEventSymbols.removeAttributeStringByKey(symbol, CandlePrice.attributeKey) :
        try? MarketEventSymbols.changeAttributeStringByKey(symbol, CandlePrice.attributeKey, toString())
    }

    /// Internal method that initializes attribute in the candle symbol.
    public func checkInAttribute(candleSymbol: CandleSymbol) throws {
        if candleSymbol.price != nil {
            throw ArgumentException.invalidOperationException("Already initialized")
        }
        candleSymbol.price = self
    }
}
