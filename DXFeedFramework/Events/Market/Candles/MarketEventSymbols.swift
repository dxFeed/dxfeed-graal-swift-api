//
//  MarketEventSymbols.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 14.07.23.
//

import Foundation

class MarketEventSymbols {
    enum Separtors: String {
        case exchSeparator = "&"
        case open = "{"
        case close = "}"
        case separator = ","
        case value = "="
    }

    static func changeExchangeCode(_ symbol: String?, _ exchangeCode: Character) -> String? {
        guard let symbol = symbol else {
            return exchangeCode == "\0" ? nil : "\(Separtors.exchSeparator.rawValue)\(exchangeCode)"
        }

        let index = getLengthWithoutAttributesInternal(symbol)
        let result = exchangeCode == "\0" ?
        getBaseSymbolInternal(symbol, index) :
        (getBaseSymbolInternal(symbol, index) + "\(Separtors.exchSeparator.rawValue)\(exchangeCode)")

        return index == symbol.length ?
        result :
        result + symbol[index]
    }

    static func getBaseSymbol(_ symbol: String?) -> String? {
        guard let symbol = symbol else {
            return nil
        }
        return getBaseSymbolInternal(symbol, getLengthWithoutAttributesInternal(symbol))
    }

    private static func hasExchangeCodeInternal(_ symbol: String, _ length: Int) -> Bool {
        return  length >= 2 && symbol[length - 2] == Separtors.exchSeparator.rawValue
    }

    private static func getBaseSymbolInternal(_ symbol: String, _ length: Int) -> String {
        return hasExchangeCodeInternal(symbol, length) ? symbol[0..<(length - 2)] : symbol[0..<length]
    }

    static func getAttributeStringByKey(_ symbol: String?, _ key: String?) throws -> String? {
        guard let key = key else {
            throw ArgumentException.argumentNil
        }
        guard let symbol = symbol else {
            return nil
        }
        return getAttributeInternal(symbol, getLengthWithoutAttributesInternal(symbol), key)
    }

    private  static func getAttributeInternal(_ symbol: String, _ lenght: Int, _ key: String) -> String? {
        if lenght == symbol.length {
            return nil
        }
        var index = lenght + 1
        while index < symbol.length {
            let current = getKeyInternal(symbol, index)
            if current == nil {
                break
            }
            let jindex = getNextKeyInternal(symbol, index)
            if key == current {
                return getValueInternal(symbol, index, jindex)
            }
            index = jindex
        }
        return nil
    }

    private static func getLengthWithoutAttributesInternal(_ symbol: String) -> Int {
        let length = symbol.length
        if hasAttributesInternal(symbol, length) {
            let last = symbol.lastIndex(of: Separtors.open.rawValue, start: length)
            return last
        } else {
            return length
        }
    }

    private static func hasAttributesInternal(_ symbol: String,
                                              _ length: Int) -> Bool {
        if length >= 3 && symbol[length - 1] == Separtors.close.rawValue {
            let lastIndex = symbol.lastIndex(of: Separtors.open.rawValue, start: length - 2)
            return lastIndex >= 0 && lastIndex < length - 1
        }
        return false
    }

    private static func getKeyInternal(_ symbol: String,
                                       _ start: Int) -> String? {
        let val = symbol.firstIndex(of: Separtors.value.rawValue, start: start)
        return val < 0 ? nil : symbol[start..<val]
    }

    private static func getNextKeyInternal(_ symbol: String,
                                           _ index: Int) -> Int {
        let val = symbol.firstIndex(of: Separtors.value.rawValue, start: index) + 1
        let sep = symbol.firstIndex(of: Separtors.separator.rawValue, start: val)
        return sep < 0 ? symbol.length : sep + 1
    }

    private static func getValueInternal(_ symbol: String,
                                         _ index: Int,
                                         _ jindex: Int) -> String {
        let startPos = symbol.firstIndex(of: Separtors.value.rawValue, start: index) + 1
        let endPos = jindex - 1
        return symbol[startPos..<endPos]
    }

    static func removeAttributeStringByKey(_ symbol: String?,
                                           _ key: String) -> String? {
        guard let symbol = symbol else {
            return nil
        }
        return removeAttributeInternal(symbol,
                                       getLengthWithoutAttributesInternal(symbol),
                                       key)
    }

    private static func removeAttributeInternal(_ symbol: String,
                                                _ length: Int,
                                                _ key: String) -> String {
        var symbol = symbol
        if length == symbol.length {
            return symbol
        }
        var index = length + 1
        while index < symbol.length {
            let current = getKeyInternal(symbol, index)
            if current == nil {
                break
            }

            let jindex = getNextKeyInternal(symbol, index)
            if key == current {
                symbol = dropKeyAndValueInternal(symbol, length, index, jindex)
            } else {
                index = jindex
            }
        }

        return symbol
    }

    private static func dropKeyAndValueInternal(_ symbol: String,
                                                _ length: Int,
                                                _ index: Int,
                                                _ jindex: Int) -> String {
        var result = ""
        if jindex == symbol.length {
            result = index == length + 1
            ? symbol[0..<length]
            : symbol[0..<index-1] + symbol[jindex - 1..<symbol.length]
        } else {
            result = symbol[0..<index] + symbol[jindex..<symbol.length]
        }

        return result
    }

    static func changeAttributeStringByKey(_ symbol: String?,
                                           _ key: String?,
                                           _ value: String?) throws -> String? {
        guard let key = key else {
            throw ArgumentException.argumentNil
        }
        guard let symbol = symbol else {
            if let value = value {
                return "\(Separtors.open)\(key)\(Separtors.value)\(value)\(Separtors.close)"
            } else {
                return nil
            }
        }
        let index = getLengthWithoutAttributesInternal(symbol)
        if index == symbol.length {
            if let value = value {
                return "\(symbol)\(Separtors.open.rawValue)\(key)\(Separtors.value.rawValue)\(value)\(Separtors.close.rawValue)"
            } else {
                return symbol
            }
        }
        if let value = value {
            return addAttributeInternal(symbol, index, key, value)
        } else {
            return removeAttributeInternal(symbol, index, key)
        }
    }

    private static func addAttributeInternal(_ symbol: String,
                                             _ length: Int,
                                             _ key: String,
                                             _ value: String) -> String {
        var symbol = symbol
        if length == symbol.length {
            return "\(symbol)\(Separtors.open.rawValue)\(key)\(Separtors.value.rawValue)\(value)\(Separtors.close.rawValue)"
        }
        var index = length + 1
        var added = false
        while index < symbol.length {
            let current = getKeyInternal(symbol, index)
            if let current = current {
                let jindex = getNextKeyInternal(symbol, index)
                if current == key {
                    if added {
                        // Drop, since we've already added this key.
                        symbol = dropKeyAndValueInternal(symbol, length, index, jindex)
                    } else {
                        // Replace value.
                        symbol =
                        symbol[0..<index] +
                        "\(key)\(Separtors.value.rawValue)\(value)" +
                        symbol[jindex-1..<symbol.length]
                    }
                } else {
                    if current > key && !added {
                        // Insert value here.
                        symbol =
                        symbol[0..<index] +
                        "\(key)\(Separtors.value.rawValue)\(value)\(Separtors.separator.rawValue)" +
                        symbol[index..<symbol.length]
                        added = true
                        index += key.length + value.length + 2
                    } else {
                        index = jindex
                    }
                }
            }
        }
        return added ? symbol : (symbol[0..<index-1] +
                                 "\(Separtors.separator.rawValue)\(key)\(Separtors.value.rawValue)\(value)" +
                                 symbol[index-1..<symbol.length])
    }

    static func getExchangeCode(_ symbol: String?) -> Character {
        let emptyChar: Character = "\0"
        if hasExchangeCode(symbol), let symbol = symbol {
            let str = symbol[getLengthWithoutAttributesInternal(symbol) - 1]
            guard let char = str.first else {
                return emptyChar
            }
            return char
        } else {
            return emptyChar
        }
    }

    public static func hasExchangeCode(_ symbol: String?) -> Bool {
        guard let symbol = symbol else {
            return false
        }
        return hasExchangeCodeInternal(symbol, getLengthWithoutAttributesInternal(symbol))
    }

    private static func hasExchangeCodeInternal(symbol: String, length: Int) -> Bool {
        return length >= 2 && symbol[length - 2] == Separtors.exchSeparator.rawValue
    }
}
