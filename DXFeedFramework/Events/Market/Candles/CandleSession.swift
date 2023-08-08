//
//  CandleSession.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 14.07.23.
//

import Foundation

class CandleSession {
    public typealias AttributeType = CandleSession

    static func normalizeAttributeForSymbol(_ str: String?) -> String {
#warning("TODO: implement it")
        return ""
    }

    static func getAttribute(_ str: String?) -> AttributeType {
        return AttributeType()
    }
}
