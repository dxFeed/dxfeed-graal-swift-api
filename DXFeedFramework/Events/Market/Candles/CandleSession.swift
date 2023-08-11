//
//  CandleSession.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 14.07.23.
//

import Foundation
public struct DXCandleSession: Equatable {
    public let name: String
    public let string: String
}

extension DXCandleSession: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        switch stringLiteral {
        case "Any":
            name = "Any"
            string = "false"
        case "Regular":
            name = "Regular"
            string = "true"
        default:
            name = "Any"
            string = "false"
        }
    }
}


enum CandleSession: DXCandleSession, CaseIterable {
    case any = "Any"
    case regular = "Regular"

    static let attributeKey = "tho"

    static let defaultSession = CandleSession.any

    static func normalizeAttributeForSymbol(_ symbol: String) -> String {
        let attribute = MarketEventSymbols.getAttributeStringByKey(symbol, attributeKey)
        guard let attribute = attribute else {
            return symbol
        }
        let other = Bool(attribute)
        if other == true && attribute != regular.toString() {
            if let changedSymbol = try? MarketEventSymbols.changeAttributeStringByKey(symbol,
                                                                                      attributeKey,
                                                                                      regular.toString()) {
                return changedSymbol
            }
        }
        if other == false || other == nil {
            _ = MarketEventSymbols.removeAttributeStringByKey(symbol, attributeKey)
        }
        return symbol
    }

    static func getAttribute(_ symbol: String?) -> CandleSession {
        guard let attribute = MarketEventSymbols.getAttributeStringByKey(symbol, attributeKey) else {
            return defaultSession
        }
        let res = Bool(attribute) ?? false
        return res ? regular : defaultSession
    }

    static func parse(_ symbol: String) throws -> CandleSession {
        let length = symbol.length
        if length == 0 {
            throw ArgumentException.missingCandleSession
        }
        let sValue = CandleSession.allCases.first { session in
            let sString = session.toString()
            return sString.length >= length && sString[0..<length].equalsIgnoreCase(symbol)
        }
        guard let sValue = sValue else {
            throw ArgumentException.unknowCandleSession
        }
        return sValue
    }

    func toString() -> String {
        return self.rawValue.string
    }
}

extension CandleSession: ICandleSymbolProperty {
    func changeAttributeForSymbol(symbol: String?) -> String? {
        if self == CandleSession.defaultSession {
            MarketEventSymbols.removeAttributeStringByKey(symbol, CandleSession.attributeKey)
        } else {
            try? MarketEventSymbols.changeAttributeStringByKey(symbol, CandleSession.attributeKey, toString())
        }
    }

    func checkInAttribute(candleSymbol: CandleSymbol) throws {
        if candleSymbol.session != nil {
            throw ArgumentException.invalidOperationException("Already initialized")
        }
        candleSymbol.session = self
    }
}
