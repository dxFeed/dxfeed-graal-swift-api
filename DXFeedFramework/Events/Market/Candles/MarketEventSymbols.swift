//
//  MarketEventSymbols.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 14.07.23.
//

import Foundation

class MarketEventSymbols {
    enum Separtors: String {
        case exchangeSeparator = "&"
        case attributesOpen = "{"
        case attributesClose = "}"
        case attributesSeparator = ","
        case attributeValue = "="
    }

    static func getBaseSymbol(_ symbol: String?) -> String? {
        guard let symbol = symbol else {
            return nil
        }
        return symbol
    }

    private static func hasExchangeCodeInternal(symbol: String, length: Int) -> Bool {
        return  length >= 2 && symbol[length - 2] == Separtors.exchangeSeparator.rawValue
    }

    private static func getBaseSymbolInternal(symbol: String, length: Int) -> String {
        return hasExchangeCodeInternal(symbol: symbol, length: length) ? symbol[0..<(length - 2)] : symbol[0..<length]
    }

    static func getAttributeStringByKey(_ symbol: String?, _ key: String) -> String? {
        guard let symbol = symbol else {
            return nil
        }
        return getAttributeInternal(symbol, lenght: getLengthWithoutAttributesInternal(symbol: symbol), key: key)
    }

    private  static func getAttributeInternal(_ symbol: String, lenght: Int, key: String) -> String? {
        if lenght == symbol.length {
            return nil
        }
        var index = lenght + 1
        while index < symbol.length {
            let current = getKeyInternal(symbol: symbol, start: index)
            if current == nil {
                break
            }
            let jindex = getNextKeyInternal(symbol: symbol, index: index)
            if key == current {
                return getValueInternal(symbol: symbol, index: index, jindex: jindex)
            }
            index = jindex
        }
        return nil
    }

    private static func getLengthWithoutAttributesInternal(symbol: String) -> Int {
        var length = symbol.count
        return hasAttributesInternal(symbol: symbol, length: length) ?
        symbol.lastIndex(of: Separtors.attributesOpen.rawValue, start: length) :
        length
    }

    private static func hasAttributesInternal(symbol: String, length: Int) -> Bool {
        if length >= 3 && symbol[length - 1] == Separtors.attributesClose.rawValue {
            let lastIndex = symbol.lastIndex(of: Separtors.attributesOpen.rawValue, start: length - 2)
            return lastIndex >= 0 && lastIndex < length - 1
        }
        return false
    }

    private static func getKeyInternal(symbol: String, start: Int) -> String? {
        let val = symbol.firstIndex(of: Separtors.attributeValue.rawValue, start: start)
        return val < 0 ? nil : symbol[start..<val+1]
    }

    private static func getNextKeyInternal(symbol: String, index: Int) -> Int {
        var val = symbol.firstIndex(of: Separtors.attributeValue.rawValue, start: index) + 1
        var sep = symbol.firstIndex(of: Separtors.attributesSeparator.rawValue, start: val)
        return sep < 0 ? symbol.count : sep + 1;
    }

    private static func getValueInternal(symbol: String, index: Int, jindex: Int) -> String {
        var startPos = symbol.firstIndex(of: Separtors.attributeValue.rawValue, start: index) + 1
        var endPos = jindex - 1
        return symbol[startPos..<endPos]
    }


    public static func RemoveAttributeStringByKey(string? symbol, string? key) -> String? {        
            if (key == null)
            {
                throw new ArgumentNullException(nameof(key));
            }

            if (symbol == null)
            {
                return null;
            }

            return RemoveAttributeInternal(symbol, GetLengthWithoutAttributesInternal(symbol), key);
        }
}
