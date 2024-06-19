//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

/// A list of all events, that can be passed to/from native code, represented as a numeric code.
///
/// In a particular case, these are implementations ``IEventType``
public enum EventCode: CaseIterable {
    /// See ``Quote``
    case quote
    /// See ``Profile``
    case profile
    /// See ``Summary``
    case summary
    /// See ``Greeks``
    case greeks
    /// See ``Candle``
    case candle
    /// **Deprecated. Doesn't need to be implemented**
    case dailyCandle
    /// See ``Underlying``
    case underlying
    /// See ``TheoPrice``
    case theoPrice
    /// See ``Trade``
    case trade
    /// See ``TradeETH``
    case tradeETH
    /// **Not implemented**
    case configuration
    /// **Not implemented**
    case message
    /// See ``TimeAndSale``
    case timeAndSale
    /// **Doesn't need to be implemented. Abstract class**
    case orderBase
    /// See ``AnalyticOrder``
    case order
    /// See ``AnalyticOrder``
    case analyticOrder
    /// See ``SpreadOrder``
    case spreadOrder
    /// See ``Series``
    case series
    /// See ``OptionSale``
    case optionSale
}

public extension EventCode {
    static func unsupported() -> [EventCode] {
        return [.dailyCandle, .configuration, .message, .orderBase]
    }
}

public extension EventCode {
    func isTimeSeriesEvent() -> Bool {
        return self == .candle ||
            self == .timeAndSale ||
            self == .greeks ||
            self == .underlying ||
            self == .theoPrice
    }
}
