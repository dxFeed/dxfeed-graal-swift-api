//
//  SpreadOrder.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 11.10.23.
//

import Foundation

/// Spread order event is a snapshot for a full available market depth for all spreads
/// on a given underlying symbol.
///
/// The collection of spread order events of a symbol
/// represents the most recent information that is available about spread orders on
/// the market at any given moment of time.
///
/// Spread order is similar to a regular ``Order``, but it has a
/// ``SpreadSymbol`` property that contains the symbol
/// of the actual spread that is being represented by spread order object.
/// ``MarketEvent.EventSymbol`` property contains the underlying symbol
/// that was used in subscription.
///
/// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/market/SpreadOrder.html)
public class SpreadOrder: OrderBase {

    /// Gets or sets spread symbol of this event.
    public var spreadSymbol: String?

    public override init(_ eventSymbol: String) {
        super.init(eventSymbol)
    }

    /// Returns string representation of this candle event.
    override func toString() -> String {
        return
"""
SpreadOrder{\(baseFieldsToString()), \
spreadSymbol=\(spreadSymbol ?? "null")}
"""
    }
}
