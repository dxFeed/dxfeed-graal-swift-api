//
//  TradingStatus.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 22.08.23.
//

import Foundation

/// Trading status of an instrument.
public enum TradingStatus: Int, CaseIterable {
    /// Trading status is undefined, unknown or inapplicable.
    case undefined = 0
    /// Trading is halted.
    case halted
    /// Trading is active.
    case active

    static let values: [TradingStatus] = {
        EnumUtil.createEnumBitMaskArrayByValue(defaultValue: .undefined, allCases: TradingStatus.allCases)
    }()

    /// Returns an enum constant of the ``TradingStatus`` by integer code bit pattern.
    public static func valueOf(_ value: Int) -> TradingStatus {
        return TradingStatus.values[value]
    }
}
