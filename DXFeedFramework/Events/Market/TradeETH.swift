//
//  TradeETH.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 15.09.23.
//

import Foundation

/// TradeETH event is a snapshot of the price and size of the last trade during
/// extended trading hours and the extended trading hours day volume and day turnover.
///
/// This event is defined only for symbols (typically stocks and ETFs) with a designated
/// extended trading hours (ETH, pre market and post market trading sessions).
/// It represents the most recent information that is available about
/// ETH last trade on the market at any given moment of time.
///
/// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/market/TradeETH.html)
public class TradeETH: TradeBase {
    public override var type: EventCode {
        return .tradeETH
    }

    /// Returns string representation of this trade event.
    public override func toString() -> String {
        return "TradeETH{\(baseFieldsToString())}"
    }
}
