//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

/// Identifies source of ``Order``, ``AnalyticOrder``, OtcMarketsOrder and ``SpreadOrder`` events.
///
/// There are the following kinds of order sources:
///
/// Synthetic sources ``compsoiteBid``, ``compsoiteAsk``,
///     ``regionalBid``, and ``regionalAsk`` are provided for convenience of a consolidated
///     order book and are automatically generated based on the corresponding ``Quote`` events.
/// Aggregate sources ``agregateBid`` and ``agregateAsk`` provide
///     futures depth (aggregated by price level) and NASDAQ Level II (top of book for each market maker).
///     These source cannot be directly published to via dxFeed API.
/// ``isPublishable(eventType:)`` sources ``defaultOrderSource``, ``NTV-773uf``, and ``ISE``
///     support full range of dxFeed API features.
///
///

public class OrderSource: IndexedEventSource {
    private static let pubOrder = 0x0001
    private static let pubAnalyticOrder = 0x0002
    private static let pubOtcMarketsOrder = 0x0004
    private static let pubSpreadOrder = 0x0008
    private static let fullOrderBook = 0x0010
    private static let flagsSize = 5

    private let pubFlags: Int
    private let isBuiltin: Bool

    static private let sourcesById = ConcurrentDict<Int, OrderSource>()
    static private let sourcesByName = ConcurrentDict<String, OrderSource>()
    private let sourcesByIdCache = NSCache<AnyObject, OrderSource>()

    /// The default source with zero identifier for all events that do not support multiple sources.
    public static let defaultOrderSource =
    try? OrderSource(0, "DEFAULT", pubOrder | pubAnalyticOrder | pubOtcMarketsOrder | pubSpreadOrder | fullOrderBook)

    /// Bid side of a composite ``Quote``
    ///
    /// It is a synthetic source.
    /// The subscription on composite ``Quote`` event is observed when this source is subscribed to.
    public static let compsoiteBid =
    try? OrderSource(1, "COMPOSITE_BID", pubOrder | pubAnalyticOrder | pubSpreadOrder | fullOrderBook)
    /// Ask side of a composite ``Quote``.
    /// It is a synthetic source.
    /// The subscription on composite ``Quote`` event is observed when this source is subscribed to.
    public static let compsoiteAsk = try? OrderSource(2, "COMPOSITE_ASK", 0)
    /// Bid side of a regional ``Quote``.
    /// It is a synthetic source.
    /// The subscription on regional ``Quote`` event is observed when this source is subscribed to.

    public static let regionalBid = try? OrderSource(3, "REGIONAL_BID", 0)
    /// Ask side of a regional ``Quote``.
    /// It is a synthetic source.
    /// The subscription on regional ``Quote`` event is observed when this source is subscribed to.

    public static let regionalAsk = try? OrderSource(4, "REGIONAL_ASK", 0)
    /// Bid side of an aggregate order book (futures depth and NASDAQ Level II).
    /// This source cannot be directly published via dxFeed API, but otherwise it is fully operational.
    public static let agregateBid = try? OrderSource(5, "AGGREGATE_BID", 0)

    /// Ask side of an aggregate order book (futures depth and NASDAQ Level II).
    /// This source cannot be directly published via dxFeed API, but otherwise it is fully operational.
    public static let agregateAsk = try? OrderSource(6, "AGGREGATE_ASK", 0)

    /// NASDAQ Total View.
    public static let NTV = try? OrderSource("NTV", pubOrder | fullOrderBook)

    /// NASDAQ Total View. Record for price level book.
    public static let ntv = try? OrderSource("ntv", pubOrder)

    /// NASDAQ Futures Exchange.
    public static let NFX = try? OrderSource("NFX", pubOrder)

    /// NASDAQ eSpeed.
    public static let ESPD = try? OrderSource("ESPD", pubOrder)

    /// NASDAQ Fixed Income.
    public static let XNFI = try? OrderSource("XNFI", pubOrder)

    /// Intercontinental Exchange.
    public static let ICE = try? OrderSource("ICE", pubOrder)

    /// International Securities Exchange.
    public static let ISE = try? OrderSource("ISE", pubOrder | pubSpreadOrder)

    /// Direct-Edge EDGA Exchange.
    public static let DEA = try? OrderSource("DEA", pubOrder)

    /// Direct-Edge EDGX Exchange.
    public static let DEX = try? OrderSource("DEX", pubOrder)

    /// Bats BYX Exchange.
    public static let BYX = try? OrderSource("BYX", pubOrder)

    /// Bats BZX Exchange.
    public static let BZX = try? OrderSource("BZX", pubOrder)

    /// Bats Europe BXE Exchange.
    public static let BATE = try? OrderSource("BATE", pubOrder)

    /// Bats Europe CXE Exchange.
    public static let CHIX = try? OrderSource("CHIX", pubOrder)

    /// Bats Europe DXE Exchange.
    public static let CEUX = try? OrderSource("CEUX", pubOrder)

    /// Bats Europe TRF.
    public static let BXTR = try? OrderSource("BXTR", pubOrder)

    /// Borsa Istanbul Exchange.
    public static let IST = try? OrderSource("IST", pubOrder)

    /// Borsa Istanbul Exchange. Record for particular top 20 order book.
    public static let BI20 = try? OrderSource("BI20", pubOrder)

    /// ABE (abe.io) exchange.
    public static let ABE = try? OrderSource("ABE", pubOrder)

    /// FAIR (FairX) exchange.
    public static let FAIR = try? OrderSource("FAIR", pubOrder)

    /// CME Globex.
    public static let GLBX = try? OrderSource("GLBX", pubOrder | pubAnalyticOrder)

    /// CME Globex. Record for price level book.
    public static let glbx = try? OrderSource("glbx", pubOrder)

    /// Eris Exchange group of companies.
    public static let ERIS = try? OrderSource("ERIS", pubOrder)

    /// Eurex Exchange.
    public static let XEUR = try? OrderSource("XEUR", pubOrder)

    /// Eurex Exchange. Record for price level book.
    public static let xeur = try? OrderSource("xeur", pubOrder)

    /// CBOE Futures Exchange.
    public static let CFE = try? OrderSource("CFE", pubOrder)

    /// CBOE Options C2 Exchange.
    public static let C2OX = try? OrderSource("C2OX", pubOrder)

    /// Small Exchange.
    public static let SMFE = try? OrderSource("SMFE", pubOrder)

    /// Small Exchange. Record for price level book.
    public static let smfe = try? OrderSource("smfe", pubOrder)

    /// Investors exchange. Record for price level book.
    public static let iex = try? OrderSource("iex", pubOrder)

    /// Members Exchange.
    public static let MEMX = try? OrderSource("MEMX", pubOrder)

    /// Members Exchange. Record for price level book.
    public static let memx = try? OrderSource("memx", pubOrder)

    /// Blue Ocean Technologies Alternative Trading System.
    /// ``Order`` events are publishable on this
    ///  source and the corresponding subscription can be observed via ``DXPublisher``.
    public static let OCEA = try? OrderSource("OCEA", pubOrder)

    /// Pink Sheets. Record for price level book.
    /// Pink sheets are listings for stocks that trade over-the-counter (OTC).
    /// ``Order`` and ``OtcMarketsOrder`` events are publishable on this
    /// source and the corresponding subscription can be observed via ``DXPublisher``
    public static let pink = try? OrderSource("pink", pubOrder | pubOtcMarketsOrder)

    /// Don't use it. Just for initialization all static variable.
    /// static let - is always lazy initialized
    fileprivate static let allValues = [OrderSource.defaultOrderSource,
                                        OrderSource.compsoiteBid,
                                        OrderSource.compsoiteAsk,
                                        OrderSource.regionalBid,
                                        OrderSource.regionalAsk,
                                        OrderSource.agregateBid,
                                        OrderSource.agregateAsk,
                                        OrderSource.NTV,
                                        OrderSource.ntv,
                                        OrderSource.NFX,
                                        OrderSource.ESPD,
                                        OrderSource.XNFI,
                                        OrderSource.ICE,
                                        OrderSource.ISE,
                                        OrderSource.DEA,
                                        OrderSource.DEX,
                                        OrderSource.BYX,
                                        OrderSource.BZX,
                                        OrderSource.BATE,
                                        OrderSource.CHIX,
                                        OrderSource.CEUX,
                                        OrderSource.BXTR,
                                        OrderSource.IST,
                                        OrderSource.BI20,
                                        OrderSource.ABE,
                                        OrderSource.FAIR,
                                        OrderSource.GLBX,
                                        OrderSource.glbx,
                                        OrderSource.ERIS,
                                        OrderSource.XEUR,
                                        OrderSource.xeur,
                                        OrderSource.CFE,
                                        OrderSource.C2OX,
                                        OrderSource.SMFE,
                                        OrderSource.smfe,
                                        OrderSource.iex,
                                        OrderSource.MEMX,
                                        OrderSource.memx,
                                        OrderSource.pink]

    override init(_ identifier: Int, _ name: String) {
        self.pubFlags = 0
        self.isBuiltin = false
        super.init(identifier, name)
    }

    convenience init(_ name: String, _ pubFlags: Int) throws {
        try self.init(OrderSource.composeId(name: name), name, pubFlags)
    }

    init(_ identifier: Int, _ name: String, _ pubFlags: Int) throws {
        self.pubFlags = pubFlags
        self.isBuiltin = true
        super.init(identifier, name)
        switch identifier {
        case _ where identifier < 0:
            throw ArgumentException.exception("id is negative")
        case _ where identifier > 0 && identifier < 0x20 && !OrderSource.isSpecialSourceId(sourceId: identifier):
            throw ArgumentException.exception("id is not marked as special")
        case _ where identifier > 0x20:
            if try (identifier != OrderSource.composeId(name: name))
                && (name != OrderSource.decodeName(identifier: identifier)) {
                throw ArgumentException.exception("id does not match name")
            }
        default: break
        }
        // Flag FullOrderBook requires that source must be publishable.
        if OrderSource.isFullOrderBookFlag(pubFlags) && OrderSource.isPublishableFlag(pubFlags) {
            throw ArgumentException.exception("Unpublishable full order book order")
        }

        if !OrderSource.sourcesById.tryInsert(key: identifier, value: self) {
            throw ArgumentException.exception("duplicate id \(identifier)")
        }
        if !OrderSource.sourcesByName.tryInsert(key: name, value: self) {
            throw ArgumentException.exception("duplicate name \(name)")
        }
    }

    private static func isFullOrderBookFlag(_ pubFlags: Int) -> Bool {
        return (pubFlags & OrderSource.fullOrderBook) != 0
    }

    private static func isPublishableFlag(_ pubFlags: Int) -> Bool {
        let mask = OrderSource.pubOrder |
        OrderSource.pubAnalyticOrder |
        OrderSource.pubOtcMarketsOrder |
        OrderSource.pubSpreadOrder
        return (pubFlags & mask) == 0
    }

        /// Determines whether specified source identifier refers to special order source.
    /// Special order sources are used for wrapping non-order events into order events.
    internal static func isSpecialSourceId(sourceId: Int) -> Bool {
        return sourceId >= 1 && sourceId <= 6
    }

    internal static func composeId(name: String) throws -> Int {
        var sourceId = 0
        let count = name.count
        if count == 0 || count > 4 {
            return 0
        }
        for index in 0..<count {
            let char = name[index]
            try OrderSource.check(char: char)
            sourceId = (sourceId << 8) | Int(char.first?.unicodeScalars.first?.value ?? 0)
        }

        return sourceId
    }

    internal static func check(char: String) throws {
        if char.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil {
            return
        }
        throw ArgumentException.exception("Source name must contain only alphanumeric characters. Current \(char)")
    }

    internal static func decodeName(identifier: Int) throws -> String {
        if identifier == 0 {
            throw ArgumentException.exception("Source name must contain from 1 to 4 characters. Current \(identifier)")
        }
        var name = String()
        for index in stride(from: 24, through: 0, by: -8) {
            if identifier >> index == 0 { // Skip highest contiguous zeros.
                continue
            }
            let char = Character(((identifier >> index) & 0xff))
            try check(char: String(char))
            name.append(char)
        }
        return name
    }
    /// Gets a value indicating whether this source supports Full Order Book.
    public func isFullOrderBook() -> Bool {
        return (pubFlags & OrderSource.fullOrderBook) != 0
    }

    /// Gets a value indicating whether the given event type can be directly published with this source.
    ///
    /// Subscription on such sources can be observed directly via ``DXPublisher``
    /// Subscription on such sources is observed via instances of  ``GenericIndexedEventSubscriptionSymbol``
    /// - Parameters:
    ///   - eventype : Possible values ``Order``, ``AnalyticOrder``, ``SpreadOrder``
    /// - Returns: true- events can be directly published with this source
    /// - Throws: ``ArgumentException/exception(_:)``
    public func isPublishable(eventType: AnyClass.Type) throws -> Bool {
        return pubFlags & (try OrderSource.getEventTypeMask(eventType)) != 0
    }

    /// Returns order source for the specified source identifier.
    /// - Throws: ``ArgumentException/exception(_:)``
    public static func valueOf(identifier: Int) throws -> OrderSource {
        return try OrderSource.sourcesById.tryGetValue(key: identifier) {
            let name = try decodeName(identifier: identifier)
            let source = OrderSource(identifier, name)
            return source
        }
    }
    /// Returns order source for the specified source name.
    /// 
    /// The name must be either predefined, or contain at most 4 alphanumeric characters.
    /// - Throws: ``ArgumentException/exception(_:)``
    public static func valueOf(name: String) throws -> OrderSource {
        return try OrderSource.sourcesByName.tryGetValue(key: name) {
            let identifier = try composeId(name: name)
            let source = OrderSource(identifier, name)
            return source
        }
    }

    /// Gets type mask by specified event type.
    ///
    /// - Parameters:
    ///   - eventype : Possible values ``Order``, ``AnalyticOrder``, ``SpreadOrder``
    /// - Returns: The mask for event class.
    /// - Throws: ``ArgumentException/exception(_:)``
    public static func getEventTypeMask(_ eventType: AnyClass) throws -> Int {
        if eventType == Order.self {
            return pubOrder
        }

        if eventType == OtcMarketsOrder.self {
            return pubOtcMarketsOrder
        }

        if eventType == AnalyticOrder.self {
            return pubAnalyticOrder
        }

        if eventType == SpreadOrder.self {
            return pubSpreadOrder
        }
        throw ArgumentException.exception("Invalid order event type: \(eventType)")
    }

}

extension OrderSource {
    /// Don't use it. Just for initialization all static variable. 
    /// static let - is always lazy initialized
    internal static func initAllValues() {
        _ = OrderSource.allValues
    }
}
