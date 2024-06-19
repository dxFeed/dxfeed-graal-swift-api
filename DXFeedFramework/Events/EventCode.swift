//
//  EventCode.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 26.05.23.
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
    case configuration
    case message
    /// See ``TimeAndSale``
    case timeAndSale
    case orderBase
    case order
    case analyticOrder
    case spreadOrder
    case series
    case optionSale
}
