//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
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

    public init(_ symbol: String) {
        super.init(symbol: symbol, type: .tradeETH)
    }

    /// Returns string representation of this trade event.
    public override func toString() -> String {
        return "TradeETH{\(baseFieldsToString())}"
    }
}
