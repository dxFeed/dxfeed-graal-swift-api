//
//  CandleAlignment.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 14.07.23.
//

import Foundation

struct DXCandleAlignment: Equatable {
    public let name: String
    public let string: String
}

extension DXCandleAlignment: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        switch stringLiteral {
        case "Midnight":
            name = stringLiteral
            string = "m"
        case "Session":
            name = stringLiteral
            string = "s"
        default:
            name = stringLiteral
            string = "m"
        }
    }
}

enum CandleAlignment: DXCandleAlignment, CaseIterable {
    case midnight = "Midnight"
    case session = "Session"

    static let attributeKey = "a"

    static let defaultAlignment =  midnight

    static let byString = {
        let myDict = Self.allCases.reduce(into: [String: CandleAlignment]()) {
            $0[$1.toString()] = $1
        }
        return myDict
    }()

    static func normalizeAttributeForSymbol(_ symbol: String?) -> String? {
        let attribute = try? MarketEventSymbols.getAttributeStringByKey(symbol, attributeKey)
        guard let attribute = attribute else {
            return symbol
        }
        do {
            let other = try parse(attribute)
            if other == defaultAlignment {
                _ = MarketEventSymbols.removeAttributeStringByKey(symbol, attributeKey)
            }
            if attribute != other.toString() {
                return try MarketEventSymbols.changeAttributeStringByKey(symbol,
                                                                         attributeKey,
                                                                         other.toString())
            }
        } catch let error {
            print(error)
        }
        return symbol
    }

    static func parse(_ symbol: String) throws -> CandleAlignment {
        // Fast path to reverse toString result.
        if let fvalue = byString[symbol] {
            return fvalue
        }
        // Slow path for different case.
        let sValue = CandleAlignment.allCases.first( where: { value in
            return value.toString() == symbol
        })
        guard let sValue = sValue else {
            throw ArgumentException.unknowCandleAlignment
        }
        return sValue
    }

    static func getAttribute(_ symbol: String?) throws -> CandleAlignment {
        let attribute = try MarketEventSymbols.getAttributeStringByKey(symbol, attributeKey)
        guard let attribute = attribute else {
            return defaultAlignment
        }
        return try parse(attribute)
    }

    func toString() -> String {
        return self.rawValue.string
    }

    func toFullString() -> String {
        return "\(CandleAlignment.attributeKey)=\(self.rawValue.string)"
    }
}

extension CandleAlignment: ICandleSymbolProperty {
    func changeAttributeForSymbol(symbol: String?) -> String? {
        if self == CandleAlignment.defaultAlignment  {
            return MarketEventSymbols.removeAttributeStringByKey(symbol, CandleAlignment.attributeKey)
        } else {
            do {
                let res = try MarketEventSymbols.changeAttributeStringByKey(symbol, CandleAlignment.attributeKey, self.toString())
                return res
            } catch let error {
                print(error)
            }
        }
        return symbol
    }

    func checkInAttribute(candleSymbol: CandleSymbol) throws {
        if candleSymbol.alignment != nil {
            throw ArgumentException.invalidOperationException("Already initialized")
        }
        candleSymbol.alignment = self
    }
}
