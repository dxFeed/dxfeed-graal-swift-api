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
    private let typeId: CandleTypeId
    private let name: String
    private let value: String
    private let periodIntervalInMillis: Int64

    init(typeId: CandleTypeId, name: String, value: String, periodIntervalInMillis: Int64) {
        self.typeId = typeId
        self.name = name
        self.value = value
        self.periodIntervalInMillis = periodIntervalInMillis
    }

    convenience init(typeId: CandleTypeId) {
        self.init(typeId: typeId,
                  name: typeId.rawValue,
                  value: typeId.rawValue,
                  periodIntervalInMillis: typeId.periodIntervalInMillis)
    }

    convenience init(inputString: String) throws {
        if inputString.isEmpty {
            throw ArgumentException.missingCandleType
        }
        if let typeId = CandleTypeId(rawValue: inputString) {
            self.init(typeId: typeId)
            return
        }
        throw ArgumentException.unknowCandleType
    }
}
