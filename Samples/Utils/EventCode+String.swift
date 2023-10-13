//
//  EventCode+String.swift
//  PerfTestCL
//
//  Created by Aleksey Kosylo on 21.09.23.
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
