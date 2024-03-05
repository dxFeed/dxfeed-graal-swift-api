//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

/// Symbol that should be used with``DXFeedSubscription`` class
/// to subscribe for``Candle`` events.``DXFeedSubscription`` also accepts a string
/// representation of the candle symbol for subscription.
///
/// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/candle/CandleSymbol.html)
public class CandleSymbol {
    /// Returns string representation of this symbol.
    public private(set) var symbol: String?
    /// Gets base market symbol without attributes.
    public private(set) var baseSymbol: String?
    /// Gets exchange attribute of this symbol.
    public internal(set) var exchange: CandleExchange?
    /// Gets price type attribute of this symbol.
    public internal(set) var price: CandlePrice?
    /// Gets session attribute of this symbol.
    public internal(set) var session: CandleSession?
    /// Gets aggregation period of this symbol.
    public internal(set) var period: CandlePeriod?
    /// Gets alignment attribute of this symbol.
    public internal(set) var alignment: CandleAlignment?
    /// Gets price level attribute of this symbol.
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
        try? initInternal()
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
        if self.exchange == nil {
            self.exchange = CandleExchange.getAttribute(self.symbol)
        }
        if self.price == nil {
            self.price = try CandlePrice.getAttribute(self.symbol)
        }
        if self.session == nil {
            self.session = CandleSession.getAttribute(self.symbol)
        }
        if self.period == nil {
            self.period = try CandlePeriod.getAttribute(self.symbol)
        }
        if self.alignment == nil {
            self.alignment = try CandleAlignment.getAttribute(self.symbol)
        }
        if self.priceLevel == nil {
            self.priceLevel = try CandlePriceLevel.getAttribute(self.symbol)
        }
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

    func toString() -> String {
        return symbol ?? "null"
    }
    /// Converts the given string symbol into the candle symbol object.
    ///
    /// - Throws: ArgumentException/invalidOperationException(_:)
    public static func valueOf(_ symbol: String) throws -> CandleSymbol {
        return try CandleSymbol(symbol)
    }
    /// Converts the given string symbol into the candle symbol object with the specified attribute set.
    ///
    /// - Parameters:
    ///  - symbol:The string symbol.
    ///  - attributes: The attributes to set.
    /// - Throws: ArgumentException/invalidOperationException(_:)
    public static func valueOf(_ symbol: String, _ properties: [ICandleSymbolProperty]) -> CandleSymbol {
        return CandleSymbol(symbol, properties)
    }
}

extension CandleSymbol: Equatable {
    public static func == (lhs: CandleSymbol, rhs: CandleSymbol) -> Bool {
        return lhs === rhs || lhs.symbol == rhs.symbol
    }
}

extension CandleSymbol: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(symbol)
    }
}

extension CandleSymbol: Symbol {
    public var stringValue: String {
        return self.toString()
    }
}
