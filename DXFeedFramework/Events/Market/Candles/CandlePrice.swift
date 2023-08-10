//
//  CandlePrice.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 14.07.23.
//

import Foundation

final class CandlePrice: Equatable {
    static func == (lhs: CandlePrice, rhs: CandlePrice) -> Bool {
        return lhs.identifier == rhs.identifier && lhs.value == rhs.value
    }

    enum CandlePriceId: String {
        case last = "Last"
        case bid = "Bid"
        case ask = "Ask"
        case mark = "Mark"
        case settlement = "Settlement"
    }

    static let attributeKey = "price"

    private let identifier: CandlePriceId
    private let value: String
    private let name: String

    static let last = try? CandlePrice(identifier: .last, value: "last")
    static let bid = try? CandlePrice(identifier: .bid, value: "bid")
    static let ask = try? CandlePrice(identifier: .ask, value: "ask")
    static let mark = try? CandlePrice(identifier: .mark, value: "mark")
    static let settlement = try?  CandlePrice(identifier: .settlement, value: "s")

    static let defaultPrice = last

    private static let pricesByValue = ConcurrentDict<String, CandlePrice>()
    private static let pricesById = ConcurrentDict<CandlePriceId, CandlePrice>()

    private init(identifier: CandlePriceId, value: String) throws {
        self.identifier = identifier
        self.value = value
        self.name = identifier.rawValue
        CandlePrice.pricesByValue.writer { dict in
            if dict[value] == nil {
                dict[value] = self
            }
        }

        CandlePrice.pricesById.writer { dict in
            if dict[identifier] == nil {
                dict[identifier] = self
            }
        }
    }

    static func getById(identifier: CandlePriceId) -> CandlePrice? {
        return pricesById[identifier]
    }

    static func normalizeAttributeForSymbol(_ symbol: String) throws -> String {
        let attribute = MarketEventSymbols.getAttributeStringByKey(symbol, attributeKey)
        guard let value = attribute else {
            return symbol
        }
        let other = try parse(value)
        if other == defaultPrice {
            _ = MarketEventSymbols.removeAttributeStringByKey(symbol, attributeKey)
        }
        if attribute != other.value {
            return try MarketEventSymbols.changeAttributeStringByKey(symbol, attributeKey, other.toString()) ?? symbol
        }
        return symbol
    }

    static func getAttribute(_ symbol: String?) throws -> CandlePrice {
        let attribute = MarketEventSymbols.getAttributeStringByKey(symbol, attributeKey)
        guard let value = attribute else {
            return defaultPrice!
        }
        return try parse(value)
    }

    static func parse(_ symbol: String) throws -> CandlePrice {
        let length = symbol.length
        if length == 0 {
            throw ArgumentException.missingCandlePrice
        }
        // Fast path to reverse toString result.
        let fvalue = pricesByValue[symbol]
        if let value = fvalue {
            return value
        }

        // Slow path for different case.
        let sValue = pricesByValue.first { _, price in
            let pString = price.toString()
            return pString.length >= length && pString[0..<length] == symbol
        }?.value
        guard let sValue = sValue else {
            throw ArgumentException.unknowCandlePrice
        }
        return sValue
    }

    func toString() -> String {
        return value
    }
}

extension CandlePrice: ICandleSymbolProperty {
    func changeAttributeForSymbol(symbol: String?) -> String? {
        self == CandlePrice.defaultPrice ?
        MarketEventSymbols.removeAttributeStringByKey(symbol, CandlePrice.attributeKey) :
        try? MarketEventSymbols.changeAttributeStringByKey(symbol, CandlePrice.attributeKey, toString())
    }

    func checkInAttribute(candleSymbol: CandleSymbol) throws {
        if candleSymbol.price != nil {
            throw ArgumentException.invalidOperationException("Already initialized")
        }
        candleSymbol.price = self
    }
}
