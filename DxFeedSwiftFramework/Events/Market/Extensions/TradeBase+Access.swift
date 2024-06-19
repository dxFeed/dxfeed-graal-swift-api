//
//  TradeBase+Access.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 15.06.23.
//

import Foundation

extension TradeBase {
    public var time: Int64 {
        ((timeSequence >> 32) * 1000) + ((timeSequence >> 22) & 0x3ff)
    }
}
