//
//  Side.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 22.08.23.
//

import Foundation

public enum Side: Int, CaseIterable {
    case undefined = 0
    case buy
    case sell

    static let values: [Side] = {
        EnumUtil.createEnumBitMaskArrayByValue(defaultValue: .undefined, allCases: Side.allCases)
    }()

    static func valueOf(_ value: Int) -> Side {
        return Side.values[value]
    }
}
