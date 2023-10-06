//
//  OrderAction.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 06.10.23.
//

import Foundation

public enum OrderAction {
    /// Default enum value for orders that do not support "Full Order Book" and for backward compatibility -
    /// action must be derived from other ``Order``
    case undefined
    /// New Order is added to Order Book.
    case new
    /// Order is modified and price-time-priority is not maintained (i.e. order has re-entered Order Book).
    case replace
    /// Order is modified without changing its price-time-priority (usually due to partial cancel by user).
    case modify
    /// Order is fully canceled and removed from Order Book.
    case delete
    /// Size is changed (usually reduced) due to partial order execution.
    case partial
    /// Order is fully executed and removed from Order Book.
    case execute
    /// Non-Book Trade - this Trade not refers to any entry in Order Book.
    case trade
    /// Prior Trade/Order Execution bust
    case bust
}
