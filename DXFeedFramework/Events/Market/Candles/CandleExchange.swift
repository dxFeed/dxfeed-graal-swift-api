//
//  CandleExchange.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 14.07.23.
//

import Foundation

class CandleExchange {
    public typealias AttributeType = CandleExchange

    static func normalizeAttributeForSymbol(_ str: String?) -> String {
#warning("TODO: implement it")
        return ""
    }

    static func createAttribute(_ str: String?) -> AttributeType {
        return CandleExchange()
    }
}
