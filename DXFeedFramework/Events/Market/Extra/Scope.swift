//
//  Scope.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 11.10.23.
//

import Foundation

/// Scope of an order.
public enum Scope: Int, CaseIterable {
    /// Represents best bid or best offer for the whole market.
    case composite = 0

    /// Represents best bid or best offer for a given exchange code.
    case regional

    /// Represents aggregate information for a given price level or
    /// best bid or best offer for a given market maker.
    case aggregate

    /// Represents individual order on the market.
    case order
}

public class ScopeExt {
    private static let values: [Scope] =
    EnumUtil.createEnumBitMaskArrayByValue(defaultValue: .composite, allCases: Scope.allCases)

    public static func valueOf(value: Int) -> Scope {
        return values[value]
    }
}
