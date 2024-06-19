//
//  Trade.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 07.06.23.
//

import Foundation

public class Trade: TradeBase {
    func toString() -> String {
        return "Trade{\(baseFieldsToString())}"
    }
}
