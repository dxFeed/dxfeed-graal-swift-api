//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
/// Order event is a snapshot for a full available market depth for a symbol.
///
/// The collection of order events of a symbol represents the most recent information
/// that is available about orders on the market at any given moment of time.
/// Order events give information on several levels of details, called scopes - see ``Scope``.
/// Scope of an order is available via ``OrderBase/scope``property.
///
/// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/market/Order.html)
public class Order: OrderBase {
    /// Gets or sets market maker or other aggregate identifier of this order.
    /// This value is defined for ``Scope/aggregate`` and ``Scope/order`` orders.
    public var marketMaker: String?

    public convenience init(_ eventSymbol: String) {
        self.init(eventSymbol: eventSymbol, type: .order)
    }

    /// Initializes a new instance of the ``Order`` class.
    override init(eventSymbol: String, type: EventCode) {
        super.init(eventSymbol: eventSymbol, type: type)
    }

    /// Returns string representation of this candle event.
    override func toString() -> String {
        return
"""
Order{\(baseFieldsToString()), \
marketMaker='\(marketMaker ?? "null")'}
"""
    }
}
