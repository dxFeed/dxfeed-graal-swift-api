//
//  CandleType.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 14.07.23.
//

import Foundation

public class CandleType {
    public enum CandleTypeId: String, CaseIterable {
        case tick =             "t"
        case second =           "s"
        case minute =           "m"
        case hour =             "h"
        case day =              "d"
        case week =             "w"
        case month =            "mo"
        case optExp =           "o"
        case year =             "y"
        case volume =           "v"
        case price =            "p"
        case priceMomentum =    "pm"
        case priceRenko =       "pr"
    }
    static let tick = CandleType(typeId: .tick)
    static let second = CandleType(typeId: .second)
    static let minute = CandleType(typeId: .minute)
    static let hour = CandleType(typeId: .hour)
    static let day = CandleType(typeId: .day)
    static let week = CandleType(typeId: .week)
    static let month = CandleType(typeId: .month)
    static let optExp = CandleType(typeId: .optExp)
    static let year = CandleType(typeId: .year)
    static let volume = CandleType(typeId: .volume)
    static let price = CandleType(typeId: .price)
    static let priceMomentum = CandleType(typeId: .priceMomentum)
    static let priceRenko = CandleType(typeId: .priceRenko)

    private static let typesByValue = ConcurrentDict<String, CandleType>()
    private static let typesById = ConcurrentDict<CandleTypeId, CandleType>()

    private let typeId: CandleTypeId
    private let name: String
    private let value: String
    let periodIntervalInMillis: Int64
#warning("TODO: add static dict with valueByid/byType")

    init(typeId: CandleTypeId, name: String, value: String, periodIntervalInMillis: Int64) {
        self.typeId = typeId
        self.name = name
        self.value = value
        self.periodIntervalInMillis = periodIntervalInMillis

        CandleType.typesByValue.writer { dict in
            if dict[value] == nil {
                dict[value] = self
            }
        }

        CandleType.typesById.writer { dict in
            if dict[typeId] == nil {
                dict[typeId] = self
            }
        }
    }

    convenience init(typeId: CandleTypeId) {
        self.init(typeId: typeId,
                  name: typeId.rawValue,
                  value: typeId.rawValue,
                  periodIntervalInMillis: typeId.periodIntervalInMillis)
    }

//    convenience init(inputString: String) throws {
//        if inputString.isEmpty {
//            throw ArgumentException.missingCandleType
//        }
//        if let typeId = CandleTypeId(rawValue: inputString) {
//            self.init(typeId: typeId)
//            return
//        }
//        throw ArgumentException.unknowCandleType
//    }

    func toString() -> String {
        return value
    }

    static func parse(_ symbol: String) throws -> CandleType {
        let length = symbol.length
        if length == 0 {
            throw ArgumentException.missingCandleType
        }

        // Fast path to reverse toString result.
        let fValue = typesByValue[symbol]
        if let value = fValue {
            return value
        }

        // Slow path for for everything else.
        let sValue = typesByValue.first { _, value in
            let name = value.name
            if name.length >= length && name[0..<length] == symbol {
                return true
            }
            return symbol.hasSuffix("s") && name==symbol[0..<length-1]
        }
        if let value = sValue {
            return value.value
        }
        throw ArgumentException.unknowCandleType
    }
}

extension CandleType: Equatable {
    public static func == (lhs: CandleType, rhs: CandleType) -> Bool {
        return lhs === rhs ||
        (lhs.value == rhs.value && lhs.value == rhs.value && lhs.periodIntervalInMillis == rhs.periodIntervalInMillis)
    }
}
