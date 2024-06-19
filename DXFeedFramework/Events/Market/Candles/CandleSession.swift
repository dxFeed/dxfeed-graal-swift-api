//
//  CandleSession.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 14.07.23.
//

import Foundation

class CandleSession {
    enum CandleSessionId: String {
        case any = "Any"
        case regular = "Regular"
    }
    static let attributeKey = "tho"
    static let any = CandleSession(value: "false", identifier: CandleSessionId.any)
    static let regular = CandleSession(value: "true", identifier: CandleSessionId.regular)
    static let defaultSession = any

    private static let sessionsByValue = ConcurrentDict<String, CandleSession>()
    private static let sessionsById = ConcurrentDict<CandleSessionId, CandleSession>()

    let value: String
    let name: String
    let identifier: CandleSessionId

    private init(value: String, identifier: CandleSessionId) {
        self.value = value
        self.name = identifier.rawValue
        self.identifier = identifier
        CandleSession.sessionsByValue.writer { dict in
            if dict[value] == nil {
                dict[value] = self
            }
        }

        CandleSession.sessionsById.writer { dict in
            if dict[identifier] == nil {
                dict[identifier] = self
            }
        }
    }

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
        let sValue = sessionsByValue.first { _, session in
            let sString = session.toString()
            return sString.length >= length && sString[0..<length] == symbol
        }?.value
        guard let sValue = sValue else {
            throw ArgumentException.unknowCandleSession
        }
        return sValue
    }

    func toString() -> String {
        return value
    }

    func toFullString() -> String {
        return "\(CandleSession.attributeKey)=\(value)"
    }
}

extension CandleSession: ICandleSymbolProperty {
    func changeAttributeForSymbol(symbol: String?) -> String? {
        if self === CandleSession.defaultSession {
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
