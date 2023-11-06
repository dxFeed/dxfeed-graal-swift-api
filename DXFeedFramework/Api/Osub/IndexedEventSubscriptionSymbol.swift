//
//  GenericIndexedEventSubscriptionSymbol.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 01.06.23.
//

import Foundation

/// Represents subscription to a specific source of indexed events.
///
/// Instances of this class can be used with ``DXFeedSubcription``
/// to specify subscription to a particular source of indexed events.
/// By default, when subscribing to indexed events by their event symbol object,
/// the subscription is performed to all supported sources.
///
/// [Javadoc](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/osub/IndexedEventSubscriptionSymbol.html)
///
/// `T`: The type of event symbol
public class GenericIndexedEventSubscriptionSymbol<T: Equatable>: Symbol {
    /// Gets event symbol.
    let symbol: T
    /// Gets indexed event source. ``IndexedEventSource``
    let source: IndexedEventSource
    /// Initializes a new instance of the ``IndexedEventSubscriptionSymbol`` class
    /// with a specified event symbol and source.
    ///
    /// - Parameters:
    ///   - symbol: The event symbol.
    ///   - source: The event source.
    public init(symbol: T, source: IndexedEventSource) {
        self.symbol = symbol
        self.source = source
    }

    /// Custom symbol has to return string representation.
    public var stringValue: String {
        return "\(symbol)source=\(source.toString())"
    }
}

extension GenericIndexedEventSubscriptionSymbol: Equatable {
    public static func == (lhs: GenericIndexedEventSubscriptionSymbol<T>,
                           rhs: GenericIndexedEventSubscriptionSymbol<T>) -> Bool {
        return lhs === rhs || (lhs.symbol == rhs.symbol && lhs.source == rhs.source)
    }
}

/// Non-generic version, for using with Symbol protocol without equatable T
public class IndexedEventSubscriptionSymbol: Symbol {
    /// Gets event symbol.
    let symbol: Symbol
    /// Gets indexed event source. ``IndexedEventSource``
    let source: IndexedEventSource
    /// Initializes a new instance of the ``IndexedEventSubscriptionSymbol`` class
    /// with a specified event symbol and source.
    ///
    /// - Parameters:
    ///   - symbol: The event symbol.
    ///   - source: The event source.
    public init(symbol: Symbol, source: IndexedEventSource) {
        self.symbol = symbol
        self.source = source
    }

    /// Custom symbol has to return string representation.
    public var stringValue: String {
        return "\(symbol.stringValue)source=\(source.toString())"
    }
}

extension IndexedEventSubscriptionSymbol: Equatable {
    public static func == (lhs: IndexedEventSubscriptionSymbol,
                           rhs: IndexedEventSubscriptionSymbol) -> Bool {
        return lhs === rhs || (lhs.symbol.stringValue == rhs.symbol.stringValue && lhs.source == rhs.source)
    }
}
