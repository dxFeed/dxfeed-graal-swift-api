//
//  OrderSource.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 06.10.23.
//

import Foundation

/// Identifies source of ``Order``, ``AnalyticOrder``, ``OtcMarketsOrder`` and ``SpreadOrder`` events.
///
/// There are the following kinds of order sources:
///
/// Synthetic sources ``COMPOSITE_BID``, ``COMPOSITE_ASK``,
///     ``REGIONAL_BID``, and ``REGIONAL_ASK`` are provided for convenience of a consolidated
///     order book and are automatically generated based on the corresponding ``Quote`` events.
/// Aggregate sources ``AGGREGATE_BID`` and ``AGGREGATE_ASK`` provide
///     futures depth (aggregated by price level) and NASDAQ Level II (top of book for each market maker).
///     These source cannot be directly published to via dxFeed API.
/// ``isPublishable(Class) Publishable`` sources ``DEFAULT``, ``NTV``, and ``ISE``
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

    private override init(identifier: Int, name: String) {
        self.pubFlags = 0
        self.isBuiltin = false
        super.init(identifier: identifier, name: name)
    }

    private init(identifier: Int, name: String, pubFlags: Int) throws {
        self.pubFlags = pubFlags
        self.isBuiltin = true
        super.init(identifier: identifier, name: name)
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
        default:
            print("")
        }
        // Flag FullOrderBook requires that source must be publishable.
        if (pubFlags & OrderSource.fullOrderBook) != 0 && (pubFlags & (OrderSource.pubOrder | OrderSource.pubAnalyticOrder | OrderSource.pubSpreadOrder)) == 0 {
            throw ArgumentException.exception("Unpublishable full order book order")
        }

        if !OrderSource.sourcesById.tryInsert(key: identifier, value: self) {
            throw ArgumentException.exception("duplicate id")
        }
        if !OrderSource.sourcesByName.tryInsert(key: name, value: self) {
            throw ArgumentException.exception("duplicate name")
        }
    }

    /// Determines whether specified source identifier refers to special order source.
    ///Special order sources are used for wrapping non-order events into order events.
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
            var char = Character(((identifier >> index) & 0xff))
            try check(char: String(char))
            name.append(char)
        }
        return name
    }
    /// Gets a value indicating whether this source supports Full Order Book.
    public func isFullOrderBook() -> Bool {
        return (pubFlags & OrderSource.fullOrderBook) != 0
    }

    /// Returns order source for the specified source identifier.
    /// - Throws: ``ArgumentException/exception(_:)``. Rethrows exception from Java.
    public static func valueOf(identifier: Int) throws -> OrderSource {
        var source: OrderSource
        if let source = sourcesById[identifier] {
            return source
        } else {
            let name = try decodeName(identifier: identifier)
            let source = OrderSource(identifier: identifier, name: name)
            sourcesById[identifier] = source
            return source
        }
    }
    /// Returns order source for the specified source name.
    /// 
    /// The name must be either predefined, or contain at most 4 alphanumeric characters.
    /// - Throws: ``ArgumentException/exception(_:)``. Rethrows exception from Java.
    public static func valueOf(name: String) throws -> OrderSource {
        var source: OrderSource
        if let source = sourcesByName[name] {
            return source
        } else {
            let identifier = try composeId(name: name)
            let source = OrderSource(identifier: identifier, name: name)
            sourcesByName[name] = source
            return source
        }

    }

}
