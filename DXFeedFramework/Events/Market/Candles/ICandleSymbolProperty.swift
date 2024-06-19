//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
