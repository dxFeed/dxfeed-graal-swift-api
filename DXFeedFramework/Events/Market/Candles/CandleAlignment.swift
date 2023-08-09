//
//  CandleAlignment.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 14.07.23.
//

import Foundation

class CandleAlignment {
    enum CandleAlignmentId: String {
        case midnight = "Midnight"
        case session = "Session"
    }
    static let attributeKey = "a"
    private static let alignmentByValue = ConcurrentDict<String, CandleAlignment>()
    private static let alignmentById = ConcurrentDict<CandleAlignmentId, CandleAlignment>()

    static let midnight = CandleAlignment(identifier: .midnight, value: "m")
    static let session = CandleAlignment(identifier: .session, value: "s")
    static let defaultAlignment =  midnight

    let identifier: CandleAlignmentId
    let name: String
    let value: String

    private init(identifier: CandleAlignmentId, value: String) {
        self.identifier = identifier
        self.name = identifier.rawValue
        self.value = value

        CandleAlignment.alignmentByValue.writer { dict in
            if dict[value] == nil {
                dict[value] = self
            }
        }
        CandleAlignment.alignmentById.writer { dict in
            if dict[identifier] == nil {
                dict[identifier] = self
            }
        }
    }

    static func normalizeAttributeForSymbol(_ symbol: String) throws -> String {
        let attribute = MarketEventSymbols.getAttributeStringByKey(symbol, attributeKey)
        guard let attribute = attribute else {
            return symbol
        }
        let other = try parse(attribute)
        if other === defaultAlignment {
            MarketEventSymbols.removeAttributeStringByKey(symbol, attributeKey)
        }
        if attribute != other.toString() {
            if let changedSymbol =  try MarketEventSymbols.changeAttributeStringByKey(symbol, attributeKey, other.toString()) {
                return changedSymbol
            }
        }
        return symbol
    }

    static func parse(_ symbol: String) throws -> CandleAlignment {
        // Fast path to reverse toString result.
        let fvalue = alignmentByValue[symbol]
        if let value = fvalue {
            return value
        }
        // Slow path for different case.
        let sValue = alignmentByValue.first { _, value in
            return value.toString() == symbol
        }?.value
        guard let sValue = sValue else {
            throw ArgumentException.unknowCandleAlignment
        }
        return sValue

    }

    static func getAttribute(_ symbol: String?) throws -> CandleAlignment {
        let attribute = MarketEventSymbols.getAttributeStringByKey(symbol, attributeKey)
        guard let attribute = attribute else {
            return defaultAlignment
        }
        return try parse(attribute)
    }

    func toString() -> String {
        return value
    }

    func toFullString() -> String {
        return "\(CandleAlignment.attributeKey)=\(value)"
    }
}

extension CandleAlignment: ICandleSymbolProperty {
    func changeAttributeForSymbol(symbol: String?) -> String? {
        self === CandleAlignment.defaultAlignment ?
        MarketEventSymbols.removeAttributeStringByKey(symbol, CandleAlignment.attributeKey) :
        try? MarketEventSymbols.changeAttributeStringByKey(symbol, CandleAlignment.attributeKey, self.toString())
    }
    
    func checkInAttribute(candleSymbol: CandleSymbol) throws {
        if candleSymbol.alignment != nil {
            throw ArgumentException.invalidOperationException("Already initialized")
        }
        candleSymbol.alignment = self
    }
}
