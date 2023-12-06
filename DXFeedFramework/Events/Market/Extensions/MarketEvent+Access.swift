//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

/// Use this extension instead of
/// checking type and cast in client side code
///
/// switch (event.type) {
///  case: .quote:
///   let quote = tsEvent.quote
extension MarketEvent {
    /// Use only for event.type is ``EventCode/quote``
    public var quote: Quote {
        return (self as? Quote)!
    }
    /// Use only for event.type is ``EventCode/timeAndSale``
    public var timeAndSale: TimeAndSale {
        return (self as? TimeAndSale)!
    }
    /// Use only for event.type is ``EventCode/trade``
    public var trade: Trade {
        return (self as? Trade)!
    }
    /// Use only for event.type is ``EventCode/tradeETH``
    public var tradeETH: TradeETH {
        return (self as? TradeETH)!
    }
    /// Use only for event.type is ``EventCode/profile``
    public var profile: Profile {
        return (self as? Profile)!
    }
    /// Use only for event.type is ``EventCode/candle``
    public var candle: Candle {
        return (self as? Candle)!
    }
    /// Use only for event.type is ``EventCode/summary``
    public var summary: Summary {
        return (self as? Summary)!
    }
    /// Use only for event.type is ``EventCode/greeks``
    public var greeks: Greeks {
        return (self as? Greeks)!
    }
    /// Use only for event.type is ``EventCode/underlying``
    public var underlying: Underlying {
        return (self as? Underlying)!
    }
    /// Use only for event.type is ``EventCode/theoPrice``
    public var theoPrice: TheoPrice {
        return (self as? TheoPrice)!
    }
    /// Use only for event.type is ``EventCode/order``
    public var order: Order {
        return (self as? Order)!
    }
    /// Use only for event.type is ``EventCode/spreadOrder``
    public var spreadOrder: SpreadOrder {
        return (self as? SpreadOrder)!
    }
    /// Use only for event.type is ``EventCode/analyticOrder``
    public var analyticOrder: AnalyticOrder {
        return (self as? AnalyticOrder)!
    }
    /// Use only for event.type is ``EventCode/series``
    public var series: Series {
        return (self as? Series)!
    }
    /// Use only for event.type is ``EventCode/optionSale``
    public var optionSale: OptionSale {
        return (self as? OptionSale)!
    }
}
