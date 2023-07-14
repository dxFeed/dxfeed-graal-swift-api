//
//  CandleTypeId+Ext.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 14.07.23.
//

import Foundation

public extension CandleType.CandleTypeId {
    var periodIntervalInMillis: Int64 {
        switch self {
        case .tick:
            0
        case .second:
            1000
        case .minute:
            60 * 1000
        case .hour:
            60 * 60 * 1000
        case .day:
            24 * 60 * 60 * 1000
        case .week:
            7 * 24 * 60 * 60 * 1000
        case .month:
            30 * 24 * 60 * 60 * 1000
        case .optExp:
            30 * 24 * 60 * 60 * 1000
        case .year:
            365 * 24 * 60 * 60 * 1000
        case .volume:
            0
        case .price:
            0
        case .priceMomentum:
            0
        case .priceRenko:
            0
        }
    }
}
