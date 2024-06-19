//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import DXFeedFramework

extension EventCode {
    init(string: String) {
        switch string.lowercased() {
        case "quote":
            self = .quote
        case "profile":
            self = .profile
        case "summary":
            self = .summary
        case "greeks":
            self = .greeks
        case "candle":
            self = .candle
        case "dailycandle":
            self = .dailyCandle
        case "underlying":
            self = .underlying
        case "theoprice":
            self = .theoPrice
        case "trade":
            self = .trade
        case "tradeeth":
            self = .tradeETH
        case "timeandsale":
            self = .timeAndSale
        case "order":
            self = .order
        case "analyticorder":
            self = .analyticOrder
        case "spreadorder":
            self = .spreadOrder
        case "series":
            self = .series
        case "optionsale":
            self = .optionSale
        default:
            fatalError("Please, handle this case: \(string)")
        }
    }
}
