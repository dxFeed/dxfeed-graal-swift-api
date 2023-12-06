//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
