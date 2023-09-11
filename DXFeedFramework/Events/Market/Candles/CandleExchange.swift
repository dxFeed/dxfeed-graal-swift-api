//
//  CandleExchange.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 14.07.23.
//

import Foundation
/// Exchange attribute of ``CandleSymbol`` defines exchange identifier where data is
/// taken from to build the candles.
///
/// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/candle/CandleExchange.html)
public class CandleExchange {
    /// Composite exchange where data is taken from all exchanges.
    public static let composite = CandleExchange(exchangeCode: "\0")
    /// Default exchange is ``Composite``.
    public static let defaultExchange = composite
    /// Gets exchange code.
    public let exchangeCode: Character

    private init(exchangeCode: Character) {
        self.exchangeCode = exchangeCode
    }
    /// Returns exchange attribute object that corresponds to the specified exchange code character.
    /// -  Parameters:
    ///    - char: The exchange code character.
    /// - Returns: The exchange attribute object.
    public static func valueOf(_ char: Character) -> CandleExchange {
        if char == "\0" {
            return composite
        } else {
            return CandleExchange(exchangeCode: char)
        }
    }
    /// Gets exchange attribute object of the given candle symbol string.
    ///
    /// The result is ``Default`` if the symbol does not have exchange attribute.
    /// -  Parameters:
    ///    - symbol: The candle symbol string.
    /// - Returns: exchange attribute object of the given candle symbol string.
    public static func getAttribute(_ symbol: String?) -> CandleExchange {
        return valueOf(MarketEventSymbols.getExchangeCode(symbol))
    }
    /// Returns string representation of this exchange.
    /// It is the string  "COMPOSITE"  for ``Composite`` exchange or
    /// exchange character otherwise.
    func toString() -> String {
        exchangeCode == "\0" ? "COMPOSITE" : "\(exchangeCode)"
    }
}

extension CandleExchange: ICandleSymbolProperty {
    /// Change candle event symbol string with this attribute set
    /// and returns new candle event symbol string.
    public func changeAttributeForSymbol(symbol: String?) -> String? {
        return MarketEventSymbols.changeExchangeCode(symbol, exchangeCode)
    }
    /// Internal method that initializes attribute in the candle symbol.
    /// If used outside of internal initialization logic.
    public func checkInAttribute(candleSymbol: CandleSymbol) throws {
        if candleSymbol.exchange != nil {
            throw ArgumentException.invalidOperationException("Already initialized")
        }
        candleSymbol.exchange = self
    }
}
