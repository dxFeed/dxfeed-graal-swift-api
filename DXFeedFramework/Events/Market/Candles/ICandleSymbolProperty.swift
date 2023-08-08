//
//  ICandleSymbolProperty.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 08.08.23.
//

import Foundation

protocol ICandleSymbolProperty {
    func changeAttributeForSymbol(symbol: String?) -> String?
    func checkInAttribute(candleSymbol: CandleSymbol) throws
}
