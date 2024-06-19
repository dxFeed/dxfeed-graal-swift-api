//
//  TradingStatus.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 22.08.23.
//

import Foundation

public enum TradingStatus: Int, CaseIterable {
    case undefined = 0
    case halted
    case active

    static let values: [TradingStatus] = {
        EnumUtil.createEnumBitMaskArrayByValue(defaultValue: .undefined, allCases: TradingStatus.allCases)
    }()

    static func valueOf(_ value: Int) -> TradingStatus {
        return TradingStatus.values[value]
    }
}
