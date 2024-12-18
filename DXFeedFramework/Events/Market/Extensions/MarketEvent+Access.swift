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
    /// Use only for event.type is ``EventCode/otcMarketsOrder``
    public var otcMarketsOrder: OtcMarketsOrder {
        return (self as? OtcMarketsOrder)!
    }

    /// Use only for event.type is ``EventCode/textMessage``
    public var textMessage: TextMessage {
        return (self as? TextMessage)!
    }

    /// Use only for event.type which supported  ``ILastingEvent``
    public var lastingEvent: ILastingEvent? {
        switch self.type {
        case .quote:
            return self.quote as ILastingEvent
        case .profile:
            return self.profile as ILastingEvent
        case .summary:
            return self.summary as ILastingEvent
        case .greeks:
            return self.greeks as ILastingEvent
        case .candle:
            return self.candle as ILastingEvent
        case .underlying:
            return self.underlying as ILastingEvent
        case .theoPrice:
            return self.theoPrice as ILastingEvent
        case .trade:
            return self.trade as ILastingEvent
        case .tradeETH:
            return self.tradeETH as ILastingEvent
        default:
            return nil
        }
    }

    public var indexedEvent: IIndexedEvent? {
        return self as? IIndexedEvent
    }

    public var timeSeriesEvent: ITimeSeriesEvent? {
        return self as? ITimeSeriesEvent
    }
}
