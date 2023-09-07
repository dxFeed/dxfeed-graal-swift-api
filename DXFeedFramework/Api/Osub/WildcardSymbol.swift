//
//  WildcardSymbol.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 01.06.23.
//

import Foundation

public class WildcardSymbol: Symbol {
    static let reservedPrefix = "*"
    private let symbol: String

    public static let all = WildcardSymbol(symbol: reservedPrefix)

    private init(symbol: String) {
        self.symbol = symbol
    }

    public var stringValue: String {
        return symbol
    }
}
