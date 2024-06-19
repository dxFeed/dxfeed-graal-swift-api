//
//  CandlePeriod.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 14.07.23.
//

import Foundation

class CandlePeriod {
    private static let attributeKey = "" // Empty string as attribute key is allowed!
    private static let defaultPeriodValue: Double = 1

    static let tick = CandlePeriod(value: defaultPeriodValue, type: CandleType.tick)
    static let day = CandlePeriod(value: defaultPeriodValue, type: CandleType.day)

    static let defaultPeriod = tick

    let value: Double
    let type: CandleType
    let periodIntervalMillis: Long
    lazy var stringRepresentation: String = {
        if value == CandlePeriod.defaultPeriodValue {
            return type.toString()
        }
        return Double(Long(value)) == value ? "\(Long(value))\(type.toString())" : "\(value)\(type.toString())"
    }()

    static func normalizeAttributeForSymbol(_ symbol: String?) -> String? {
        let attribute = try? MarketEventSymbols.getAttributeStringByKey(symbol, attributeKey)
        guard let value = attribute else {
            return symbol
        }
        do {
            let other = try parse(value)
            if other == defaultPeriod {
                _ = MarketEventSymbols.removeAttributeStringByKey(symbol, attributeKey)
            }
            if attribute != other.toString() {
                return try MarketEventSymbols.changeAttributeStringByKey(symbol,
                                                                         attribute,
                                                                         other.toString())
            }
        } catch let error {
            print(error)
        }
        return symbol
    }

    static func getAttribute(_ symbol: String?) throws -> CandlePeriod {
        var attribute = try MarketEventSymbols.getAttributeStringByKey(symbol, attributeKey)
        guard let attribute = attribute else {
            return defaultPeriod
        }
        return try parse(attribute)
    }

    static func parse(_ symbol: String) throws -> CandlePeriod {
        if symbol == CandleType.day.toString() {
            return day
        } else if symbol == CandleType.tick.toString() {
            return tick
        }
        var index = 0
        for jindex in 0..<symbol.length {
            let charset = CharacterSet(charactersIn: "0123456789+-.eE")
            let char = symbol[jindex]
            if char.rangeOfCharacter(from: charset) == nil {
                index = jindex
                break
            }
        }
        let value = symbol[0..<index]
        let type = symbol[index..<symbol.length]

        return valueOf(value: value.isEmpty ? 1 : Double(value)!, type: try CandleType.parse(type))

    }

    static func valueOf(value: Double, type: CandleType) -> CandlePeriod {
        if value == defaultPeriodValue {
            if type == CandleType.day {
                return day
            } else if type == .tick {
                return tick
            }
        }
        return CandlePeriod(value: value, type: type)
    }

    private init(value: Double, type: CandleType) {
        self.value = value
        self.type = type
        self.periodIntervalMillis = type.rawValue.periodIntervalMillis * Long(value)
    }

    func toString() -> String {
        return stringRepresentation
    }
}

extension CandlePeriod: Equatable {
    static func == (lhs: CandlePeriod, rhs: CandlePeriod) -> Bool {
        return lhs === rhs || (lhs.value == rhs.value && lhs.type == rhs.type)
    }
}

extension CandlePeriod: ICandleSymbolProperty {
    func changeAttributeForSymbol(symbol: String?) -> String? {
        if self === CandlePeriod.defaultPeriod {
            MarketEventSymbols.removeAttributeStringByKey(symbol, CandlePeriod.attributeKey)
        } else {
            try? MarketEventSymbols.changeAttributeStringByKey(symbol, CandlePeriod.attributeKey, toString())
        }
    }

    func checkInAttribute(candleSymbol: CandleSymbol) throws {
        if candleSymbol.period != nil {
            throw ArgumentException.invalidOperationException("already initialized")
        }
        candleSymbol.period = self
    }
}
