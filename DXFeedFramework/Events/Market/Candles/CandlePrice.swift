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
        case last
        case bid
        case ask
        case mark
        case settlement
    }

    static let attributeKey = "price"

    private let identifier: CandlePriceId
    private let value: String
    private let name: String

    static let last = CandlePrice(identifier: .last, value: "last")
    static let bid = CandlePrice(identifier: .bid, value: "bid")
    static let ask = CandlePrice(identifier: .ask, value: "ask")
    static let mark = CandlePrice(identifier: .mark, value: "mark")
    static let settlement = CandlePrice(identifier: .settlement, value: "s")

    static let defaultPrice = last

    private static let pricesByValue = ConcurrentDict<String, CandlePrice>()
    private static let pricesById = ConcurrentDict<CandlePriceId, CandlePrice>()

    private init(identifier: CandlePriceId, value: String) {
        self.identifier = identifier
        self.value = value
        self.name = identifier.rawValue
    }

    static func normalizeAttributeForSymbol(_ symbol: String) throws -> String {
        let attribute = MarketEventSymbols.getAttributeStringByKey(symbol, attributeKey)
        guard let value = attribute else {
            return symbol
        }
        let other = try parse(symbol)
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
            return defaultPrice
        }
        return try parse(value)
    }

    static func parse(_ symbol: String) throws -> CandlePrice {
        let lenght = symbol.length
        if lenght == 0 {
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
            return pString.length >= lenght && pString[0..<lenght] == symbol
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
