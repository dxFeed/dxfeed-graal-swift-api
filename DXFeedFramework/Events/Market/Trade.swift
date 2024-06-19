//
//  Trade.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 07.06.23.
//

import Foundation

/// Trade event is a snapshot of the price and size of the last trade during regular trading hours
/// and an overall day volume and day turnover.
/// 
/// It represents the most recent information that is available about the regular last trade on the market
/// at any given moment of time.
///
/// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/market/Trade.html)
public class Trade: TradeBase {
    public override var type: EventCode {
        return .trade
    }
    /// Returns string representation of this trade event.
    public override func toString() -> String {
        return "Trade{\(baseFieldsToString())}"
    }
}
