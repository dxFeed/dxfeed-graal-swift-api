//
//  CandlePrice.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 14.07.23.
//

import Foundation

public struct DXCandlePrice: Equatable {
    public let name: String
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

enum CandlePrice: DXCandlePrice, CaseIterable {
    case last = "last"
    case bid = "bid"
    case ask = "ask"
    case mark = "mark"
    case settlement = "s"

    static let attributeKey = "price"
    static let defaultPrice = last

    static let byString = {
        let myDict = Self.allCases.reduce(into: [String: CandlePrice]()) {
            $0[$1.toString()] = $1
        }
        return myDict
    }()

    static func normalizeAttributeForSymbol(_ symbol: String) throws -> String {
        let attribute = MarketEventSymbols.getAttributeStringByKey(symbol, attributeKey)
        guard let value = attribute else {
            return symbol
        }
        let other = try parse(value)
        if other == defaultPrice {
            _ = MarketEventSymbols.removeAttributeStringByKey(symbol, attributeKey)
        }
        if attribute != other.toString() {
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

    func toString() -> String {
        return self.rawValue.string
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
