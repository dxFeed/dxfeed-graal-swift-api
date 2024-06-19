//
//  CandlePriceLevel.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 14.07.23.
//

import Foundation

class CandlePriceLevel {
    public typealias AttributeType = CandlePriceLevel

    static func normalizeAttributeForSymbol(_ str: String?) -> String {
#warning("TODO: implement it")
        return ""
    }

    static func createAttribute(_ str: String?) -> AttributeType {
        return CandlePriceLevel()
    }
}
