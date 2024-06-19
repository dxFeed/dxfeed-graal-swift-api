//
//  CandlePriceLevel.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 14.07.23.
//

import Foundation

class CandlePriceLevel {

    static let attributeKey = "pl"

    let value: Double
    static let defaultCandlePriceLevel = try? CandlePriceLevel(value: Double.nan)

    lazy var stringDescription: String = {
        return Double(Long(value)) == value ? "\(Long(value))" : "\(value)"
    }()

    private init(value: Double) throws {
        if value.isInfinite || value == -0.0 {
            throw ArgumentException.incorrectCandlePrice
        }
        self.value = value
    }

    static func normalizeAttributeForSymbol(_ symbol: String?) -> String? {
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

    static func valueOf(value: Double) throws -> CandlePriceLevel {
        value.isNaN ? defaultCandlePriceLevel! : try CandlePriceLevel(value: value)
    }

    static func parse(_ symbol: String) throws -> CandlePriceLevel {
        if let value = Double(symbol) {
            return try valueOf(value: value)
        }
        throw ArgumentException.unknowCandlePriceLevel
    }

    static func getAttribute(_ symbol: String?) throws -> CandlePriceLevel {
        var attribute = try MarketEventSymbols.getAttributeStringByKey(symbol, attributeKey)
        guard let attribute = attribute else {
            return defaultCandlePriceLevel!
        }
        return try parse(attribute)
    }

    func toString() -> String {
        return stringDescription
    }

    func toFullString() -> String {
        return "\(CandlePriceLevel.attributeKey)=\(toString())"
    }
}

extension CandlePriceLevel: Equatable {
    static func == (lhs: CandlePriceLevel, rhs: CandlePriceLevel) -> Bool {
        return lhs === rhs || (lhs.value ~== rhs.value)
    }
}

extension CandlePriceLevel: ICandleSymbolProperty {
    func changeAttributeForSymbol(symbol: String?) -> String? {
        self == CandlePriceLevel.defaultCandlePriceLevel ?
        MarketEventSymbols.removeAttributeStringByKey(symbol, CandlePriceLevel.attributeKey) :
        try? MarketEventSymbols.changeAttributeStringByKey(symbol, CandlePriceLevel.attributeKey, toString())
    }

    func checkInAttribute(candleSymbol: CandleSymbol) throws {
        if candleSymbol.priceLevel != nil {
            throw ArgumentException.invalidOperationException("Already initialized")
        }
        candleSymbol.priceLevel = self
    }
}
