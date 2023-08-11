//
//  CandleSymbol.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 14.07.23.
//

import Foundation

class CandleSymbol {
    public private(set) var symbol: String?
    public private(set) var baseSymbol: String?
    public internal(set) var exchange: CandleExchange?
    public internal(set) var price: CandlePrice?
    public internal(set) var session: CandleSession?
    public internal(set) var period: CandlePeriod?
    public internal(set) var alignment: CandleAlignment?
    public internal(set) var priceLevel: CandlePriceLevel?

    private init(_ symbol: String) throws {
        self.symbol = CandleSymbol.normalize(symbol)
        try initInternal()
    }

    private init(_ symbol: String, _ properties: [ICandleSymbolProperty]) {
        self.symbol = CandleSymbol.normalize(CandleSymbol.changeAttributes(symbol, properties))
        properties.forEach { prop in
            try? prop.checkInAttribute(candleSymbol: self)
        }
    }

    private static func changeAttributes(_ symbol: String, _ properties: [ICandleSymbolProperty]) -> String {
        var symbol = symbol
        properties.forEach { prop in
            symbol = prop.changeAttributeForSymbol(symbol: symbol) ?? symbol
        }
        return symbol
    }

    private func initInternal() throws {
        self.baseSymbol = MarketEventSymbols.getBaseSymbol(self.symbol)
        self.exchange = CandleExchange.getAttribute(self.symbol)
        self.price = try CandlePrice.getAttribute(self.symbol)
        self.session = CandleSession.getAttribute(self.symbol)
        self.period = try CandlePeriod.getAttribute(self.symbol)
        self.alignment = try CandleAlignment.getAttribute(self.symbol)
        self.priceLevel = try CandlePriceLevel.getAttribute(self.symbol)
    }

    private static func normalize(_ symbol: String?) -> String? {
        var symbol = symbol
        symbol = CandlePrice.normalizeAttributeForSymbol(symbol)
        symbol = CandleSession.normalizeAttributeForSymbol(symbol)
        symbol = CandlePeriod.normalizeAttributeForSymbol(symbol)
        symbol = CandleAlignment.normalizeAttributeForSymbol(symbol)
        symbol = CandlePriceLevel.normalizeAttributeForSymbol(symbol)
        return symbol
    }

    public convenience init(symbol: String) throws {
        try self.init(symbol)
    }

    func toString() -> String {
        return symbol ?? "null"
    }

    static func valueOf(_ symbol: String) throws -> CandleSymbol {
        return try CandleSymbol(symbol: symbol)
    }

    static func valueOf(_ symbol: String, _ properties: [ICandleSymbolProperty]) -> CandleSymbol {
        return CandleSymbol(symbol, properties)
    }
}
