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
    case unknowCandleType
    case unknowCandlePrice
    case argumentNil
    case invalidOperationException(_ message: String)
}
