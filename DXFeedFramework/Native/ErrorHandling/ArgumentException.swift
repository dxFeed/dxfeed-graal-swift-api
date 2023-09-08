//
//  ArgumentException.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 14.07.23.
//

import Foundation

enum ArgumentException: Error {
    case missingCandleType
    case missingCandlePrice
    case missingCandleSession
    case unknowCandleType
    case unknowCandlePrice
    case unknowCandleAlignment
    case unknowCandleSession
    case argumentNil
    case invalidOperationException(_ message: String)
    case duplicateValue
    case duplicateId
    case incorrectCandlePrice
    case unknowCandlePriceLevel
    case illegalArgumentException
    case exception(_ message: String)
    case unknowValue(_ value: String, _ supportedValues: String? = nil)
}
