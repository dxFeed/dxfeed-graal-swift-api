//
//  Direction.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 22.08.23.
//

import Foundation

public enum Direction: Int32, CaseIterable {
    // swiftlint:disable identifier_name

    case undefined = 0
    case down
    case zeroDown
    case zero
    case zeroUp
    case up
    // swiftlint:enable identifier_name

    static let values: [Direction] = {
        EnumUtil.createEnumBitMaskArrayByValue(defaultValue: .undefined, allCases: Direction.allCases)
    }()

    static func valueOf(_ value: Int) -> Direction {
        return Direction.values[value]
    }
}
