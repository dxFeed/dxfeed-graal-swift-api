//
//  PriceType.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 06.10.23.
//

import Foundation
/// This ``DXPriceType`` structure is created to circumvent the limitation that enums in Swift cannot contain stored properties.
/// The "Enums must not contain stored properties" error occurs when attempting to add a stored property to an enum. Instead, we use this structure to store data that we would like to include in the enum.
public struct DXPriceType: Equatable {
    public let name: String
    /// Get string value of type
    public let code: Int
}

extension DXPriceType: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        switch value {
        case 0:
            name = "REGULAR"
            code = value
        case 1:
            name = "INDICATIVE"
            code = value
        case 2:
            name = "PRELIMINARY"
            code = value
        case 3:
            name = "FINAL"
            code = value
        default:
            fatalError("Try to initialize PriceType with wrong value \(value)")
        }
    }
}

public enum PriceType: DXPriceType, CaseIterable {
    case regular = 0
    case indicative = 1
    case preliminary = 2
    case final = 3

    private static let types: [PriceType] =         EnumUtil.createEnumBitMaskArrayByValue(defaultValue: .regular, allCases: PriceType.allCases)

    public static func valueOf(_ value: Int) -> PriceType {
        return PriceType.types[value]
    }
}
