//
//  Trade.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 07.06.23.
//

import Foundation

public class Trade: TradeBase {
    override func toString() -> String {
        return "Trade{\(baseFieldsToString())}"
    }
}
