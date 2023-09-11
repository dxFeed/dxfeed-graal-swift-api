//
//  ICandleSymbolProperty.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 08.08.23.
//

import Foundation

/// Property of the ``CandleSymbol``
public protocol ICandleSymbolProperty {
    /// Change candle event symbol string with this attribute set
    /// and returns new candle event symbol string.
    ///
    /// - Parameters:
    ///   - symbol: The original candle event symbol.
    /// - Returns: Returns candle event symbol string with this attribute set.
    func changeAttributeForSymbol(symbol: String?) -> String?
    /// Internal method that initializes attribute in the candle symbol.
    ///
    /// If used outside of internal initialization logic.
    /// -  Parameters:
    ///    - candleSymbol: The candle symbol
    /// - Throws: ``ArgumentException/invalidOperationException(_:)``
    func checkInAttribute(candleSymbol: CandleSymbol) throws
}
