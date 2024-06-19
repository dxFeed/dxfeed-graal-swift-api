//
//  Order.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 11.10.23.
//

import Foundation
/// Order event is a snapshot for a full available market depth for a symbol.
///
/// The collection of order events of a symbol represents the most recent information
/// that is available about orders on the market at any given moment of time.
/// Order events give information on several levels of details, called scopes - see ``Scope``.
/// Scope of an order is available via ``OrderBase.Scope``property.
///
/// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/market/Order.html)
public class Order: OrderBase {
    public override var type: EventCode {
        return .order
    }
    /// Gets or sets market maker or other aggregate identifier of this order.
    /// This value is defined for ``Scope/aggregate`` and ``Scope/order`` orders.
    public var marketMaker: String?

    /// Returns string representation of this candle event.
    override func toString() -> String {
        return
"""
Order{\(baseFieldsToString()), \
marketMaker='\(marketMaker ?? "null")'}
"""
    }
}
