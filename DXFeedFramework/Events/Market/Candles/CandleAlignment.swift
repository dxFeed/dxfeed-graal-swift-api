//
//  CandleAlignment.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 14.07.23.
//

import Foundation

/// This ``DXCandleAlignment`` structure is created to circumvent the limitation that enums in Swift cannot contain stored properties.
/// The "Enums must not contain stored properties" error occurs when attempting to add a stored property to an enum. Instead, we use this structure to store data that we would like to include in the enum.
public struct DXCandleAlignment: Equatable {
    /// Gets full name this ``CandleAlignment`` instance.
    /// For example,
    /// ``CandleAlignment/midnight`` returns "Midnight"
    /// ``CandleAlignment/session`` returns "Session"
    public let name: String
    /// Get string value of alignment
    public let string: String
}

extension DXCandleAlignment: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        switch stringLiteral {
        case "Midnight":
            name = stringLiteral
            string = "m"
        case "Session":
            name = stringLiteral
            string = "s"
        default:
            name = stringLiteral
            string = "m"
        }
    }
}

/// Candle alignment attribute of ``CandleSymbol`` defines how candle are aligned with respect to time.
///
/// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/candle/CandleAlignment.html)
public enum CandleAlignment: DXCandleAlignment, CaseIterable {
    case midnight = "Midnight"
    case session = "Session"

    static let attributeKey = "a"

    public static let defaultAlignment =  midnight

    /// A dictionary containing the matching string representation
    /// of the candle alignment attribute ``DXCandleAlignment/string`` and the ``CandleAlignment`` instance.
    static let byString = {
        let myDict = Self.allCases.reduce(into: [String: CandleAlignment]()) {
            $0[$1.toString()] = $1
        }
        return myDict
    }()

    /// Normalizes candle symbol string with representation of the candle alignment attribute.
    ///
    /// - Parameters:
    ///   - symbol: The candle symbol string.
    /// - Returns: Returns candle symbol string with the normalized representation of the candle alignment attribute.
    public static func normalizeAttributeForSymbol(_ symbol: String?) -> String? {
        let attribute = try? MarketEventSymbols.getAttributeStringByKey(symbol, attributeKey)
        guard let attribute = attribute else {
            return symbol
        }
        do {
            let other = try parse(attribute)
            if other == defaultAlignment {
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

    /// Parses string representation of candle alignment into object.
    /// Any string that was returned by ``toString()`` can be parsed
    /// and case is ignored for parsing.
    ///
    /// -  Parameters:
    ///    - symbol: The string representation of candle alignment
    /// - Returns: The candle alignment.
    /// - Throws: ``ArgumentException/unknowCandleAlignment``
    public static func parse(_ symbol: String) throws -> CandleAlignment {
        // Fast path to reverse toString result.
        if let fvalue = byString[symbol] {
            return fvalue
        }
        // Slow path for different case.
        let sValue = CandleAlignment.allCases.first( where: { value in
            return value.toString() == symbol
        })
        guard let sValue = sValue else {
            throw ArgumentException.unknowCandleAlignment
        }
        return sValue
    }
    /// Gets candle alignment of the given candle symbol string.
    ///
    /// The result is ``defaultAlignment`` if the symbol does not have candle alignment attribute.
    ///
    /// -  Parameters:
    ///    - symbol: The candle symbol string.
    /// - Returns: The candle alignment of the given candle symbol string.
    /// - Throws: ``ArgumentException/argumentNil``
    public static func getAttribute(_ symbol: String?) throws -> CandleAlignment {
        let attribute = try MarketEventSymbols.getAttributeStringByKey(symbol, attributeKey)
        guard let attribute = attribute else {
            return defaultAlignment
        }
        return try parse(attribute)
    }
    /// Returns string representation of this candle alignment.
    /// The string representation of candle alignment "m" for ``midnight``
    /// and "s" for ``session``.
    public func toString() -> String {
        return self.rawValue.string
    }
    /// Returns full string representation of this candle alignment.
    ///
    /// It is contains attribute key and its value.
    /// For example, the full string representation of ``midnight`` is "a=m".
    /// - Returns: The string representation
    public func toFullString() -> String {
        return "\(CandleAlignment.attributeKey)=\(self.rawValue.string)"
    }
}

/// Property of the ``CandleSymbol``
extension CandleAlignment: ICandleSymbolProperty {
    /// Change candle event symbol string with this attribute set
    /// and returns new candle event symbol string.
    public func changeAttributeForSymbol(symbol: String?) -> String? {
        if self == CandleAlignment.defaultAlignment {
            return MarketEventSymbols.removeAttributeStringByKey(symbol, CandleAlignment.attributeKey)
        } else {
            do {
                let res = try MarketEventSymbols.changeAttributeStringByKey(symbol,
                                                                            CandleAlignment.attributeKey,
                                                                            self.toString())
                return res
            } catch let error {
                print(error)
            }
        }
        return symbol
    }

    /// Internal method that initializes attribute in the candle symbol.
    public func checkInAttribute(candleSymbol: CandleSymbol) throws {
        if candleSymbol.alignment != nil {
            throw ArgumentException.invalidOperationException("Already initialized")
        }
        candleSymbol.alignment = self
    }
}
