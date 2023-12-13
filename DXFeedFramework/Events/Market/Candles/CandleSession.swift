//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
/// This ``DXCandleSession`` structure is created to circumvent the limitation that enums in Swift cannot contain stored properties.
/// The "Enums must not contain stored properties" error occurs when attempting to add a stored property to an enum. Instead, we use this structure to store data that we would like to include in the enum.
public struct DXCandleSession: Equatable {
    /// Gets full name this ``CandleSession`` instance.
    ///
    /// For example,
    /// ``CandleSession/any`` returns "Any",
    ///
    /// ``CandleSession/regular`` returns "Regulat"
    public let name: String
    /// Get string value of type
    public let string: String
}

extension DXCandleSession: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        switch stringLiteral {
        case "Any":
            name = "Any"
            string = "false"
        case "Regular":
            name = "Regular"
            string = "true"
        default:
            name = "Any"
            string = "false"
        }
    }
}
/// Session attribute of ``CandleSymbol`` defines trading that is used to build the candles.
///
/// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/candle/CandleSession.html)
public enum CandleSession: DXCandleSession, CaseIterable {
    /// All trading sessions are used to build candles.
    case any = "Any"
    /// Only regular trading session data is used to build candles.
    case regular = "Regular"

    /// The attribute key that is used to store the value of ``CandleSession`` in
    /// a symbol string using methods of ``MarketEventSymbols`` class.
    ///
    /// The value of this constant is "session".
    /// The value that this key shall be set to is equal to
    /// the corresponding ``toString()``
    public static let attributeKey = "tho"

    /// Default trading session is ``any``
    public static let defaultSession = CandleSession.any

    /// Normalizes candle symbol string with representation of the candle session attribute.
    ///
    /// - Parameters:
    ///   - symbol: The candle symbol string.
    /// - Returns: Returns candle symbol string with the normalized representation of the candle session attribute.
    public static func normalizeAttributeForSymbol(_ symbol: String?) -> String? {
        let attribute = try? MarketEventSymbols.getAttributeStringByKey(symbol, attributeKey)
        guard let attribute = attribute else {
            return symbol
        }
        do {
            let other = Bool(attribute)
            if other == true && attribute != regular.toString() {
                return try MarketEventSymbols.changeAttributeStringByKey(symbol,
                                                                         attributeKey,
                                                                         regular.toString())

            }
            if other == false || other == nil {
                _ = MarketEventSymbols.removeAttributeStringByKey(symbol, attributeKey)
            }
        } catch _ { }
        return symbol
    }
    /// Gets candle session of the given candle symbol string.
    ///
    /// The result is ``defaultSession`` if the symbol does not have candle session attribute.
    ///
    /// -  Parameters:
    ///    - symbol: The candle symbol string.
    /// - Returns: The candle session of the given candle symbol string.
    public static func getAttribute(_ symbol: String?) -> CandleSession {
        guard let attribute = try? MarketEventSymbols.getAttributeStringByKey(symbol, attributeKey) else {
            return defaultSession
        }
        let res = Bool(attribute) ?? false
        return res ? regular : defaultSession
    }

    /// Parses string representation of candle session  into object.
    /// Any string that was returned by ``toString()`` can be parsed
    /// and case is ignored for parsing.
    ///
    /// -  Parameters:
    ///    - symbol: The string representation of candle session
    /// - Returns: The candle session.
    /// - Throws: ``ArgumentException/missingCandleSession``, ``ArgumentException/unknowCandleSession``
    public static func parse(_ symbol: String) throws -> CandleSession {
        let length = symbol.length
        if length == 0 {
            throw ArgumentException.missingCandleSession
        }
        let sValue = CandleSession.allCases.first { session in
            let sString = session.toString()
            return sString.length >= length && sString[0..<length].equalsIgnoreCase(symbol)
        }
        guard let sValue = sValue else {
            throw ArgumentException.unknowCandleSession
        }
        return sValue
    }

    /// Returns string representation of this candle session.
    ///
    /// - Returns: The string representation.
    public func toString() -> String {
        return self.rawValue.string
    }
}

extension CandleSession: ICandleSymbolProperty {
    /// Change candle event symbol string with this attribute set
    /// and returns new candle event symbol string.
    public func changeAttributeForSymbol(symbol: String?) -> String? {
        if self == CandleSession.defaultSession {
            return MarketEventSymbols.removeAttributeStringByKey(symbol, CandleSession.attributeKey)
        } else {
            return try? MarketEventSymbols.changeAttributeStringByKey(symbol, CandleSession.attributeKey, toString())
        }
    }

    /// Internal method that initializes attribute in the candle symbol.
    public func checkInAttribute(candleSymbol: CandleSymbol) throws {
        if candleSymbol.session != nil {
            throw ArgumentException.invalidOperationException("Already initialized")
        }
        candleSymbol.session = self
    }
}
