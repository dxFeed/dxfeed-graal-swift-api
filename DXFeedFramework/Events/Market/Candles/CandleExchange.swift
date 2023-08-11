//
//  CandleExchange.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 14.07.23.
//

import Foundation

class CandleExchange {

    static let composite = CandleExchange(exchangeCode: "\0")

    static let defaultExchange = composite

    let exchangeCode: Character

    private init(exchangeCode: Character) {
        self.exchangeCode = exchangeCode
    }

    static func valueOf(_ char: Character) -> CandleExchange {
        if char == "\0" {
            return composite
        } else {
            return CandleExchange(exchangeCode: char)
        }
    }

    static func getAttribute(_ symbol: String?) -> CandleExchange {
        return valueOf(MarketEventSymbols.getExchangeCode(symbol))
    }

    func toString() -> String {
        exchangeCode == "\0" ? "COMPOSITE" : "\(exchangeCode)"
    }
}

extension CandleExchange: ICandleSymbolProperty {
    func changeAttributeForSymbol(symbol: String?) -> String? {
        return MarketEventSymbols.changeExchangeCode(symbol, exchangeCode)
    }

    func checkInAttribute(candleSymbol: CandleSymbol) throws {
        if candleSymbol.exchange != nil {
            throw ArgumentException.invalidOperationException("Already initialized")
        }
        candleSymbol.exchange = self
    }
}
