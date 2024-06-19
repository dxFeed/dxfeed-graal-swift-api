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
    public private(set) var exchange: CandleExchange?
    public private(set) var price: CandlePrice?
    public private(set) var session: CandleSession?
    public private(set) var period: CandlePeriod?
    public private(set) var alignment: CandleAlignment?
    public private(set) var priceLevel: CandlePriceLevel?

    private init(_ symbol: String) {
        self.symbol = normalize(symbol)
        initInternal()
    }

    private func initInternal() {
        self.baseSymbol = MarketEventSymbols.getBaseSymbol(self.symbol)
        self.exchange = CandleExchange.getAttribute(self.symbol)
        self.price = CandlePrice.getAttribute(self.symbol)
        self.session = CandleSession.getAttribute(self.symbol)
        self.period = CandlePeriod.getAttribute(self.symbol)
        self.alignment = CandleAlignment.getAttribute(self.symbol)
        self.priceLevel = CandlePriceLevel.getAttribute(self.symbol)
    }

    private func normalize(_ symbol: String) -> String {
        var symbol = symbol
        symbol = CandlePrice.normalizeAttributeForSymbol(symbol)
        symbol = CandleSession.normalizeAttributeForSymbol(symbol)
        symbol = CandlePeriod.normalizeAttributeForSymbol(symbol)
        symbol = CandleAlignment.normalizeAttributeForSymbol(symbol)
        symbol = CandlePriceLevel.normalizeAttributeForSymbol(symbol)
        return symbol
    }

    public convenience init(symbol: String) {
        self.init(symbol)
    }
}
