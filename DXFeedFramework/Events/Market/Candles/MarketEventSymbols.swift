//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

/// Helper class to compose and parse symbols for market events.
///
/// Regional symbols
///
/// Regional symbol subscription receives events only from a designated exchange, marketplace, or venue
/// instead of receiving composite events from all venues (by default). Regional symbol is composed from a
/// base symbol, ampersand character ('&amp;'), and an exchange code character. For example,
/// 
/// "SPY" is the symbol for composite events for SPDR S&amp;P 500 ETF from all exchanges,
/// "SPY&amp;N" is the symbol for event for SPDR S&amp;P 500 ETF that originate only from NYSE marketplace.
/// 
///
/// Symbol attributes
///
/// Market event symbols can have a number of attributes attached to then in curly braces
/// with "&lt;key&gt;=&lt;value&gt;" paris separated by commas. For example,
/// 
/// "SPY{price=bid}" is the market symbol "SPY" with an attribute key "price" set to value "bid".
/// "SPY(=5m,tho=true}" is the market symbol "SPY" with two attributes. One has an empty key and
/// value "5m", while the other has key "tho" and value "true".
/// 
/// The methods in this class always maintain attribute keys in alphabetic order.
///
/// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/market/MarketEventSymbols.html)
public class MarketEventSymbols {
    enum Separtors: String {
        case exchSeparator = "&"
        case open = "{"
        case close = "}"
        case separator = ","
        case value = "="
    }
    /// Changes exchange code of the specified symbol or removes it
    /// if new exchange code is **'\0'**.
    /// The result is **null** if old symbol is **null**.
    ///
    /// - Parameters:
    ///   - symbol: The old symbol
    ///   - exchangeCode: The new exchange code
    /// - Returns: Returns new symbol with the changed exchange code
    public static func changeExchangeCode(_ symbol: String?, _ exchangeCode: Character) -> String? {
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
    /// Returns base symbol without exchange code and attributes.
    /// The result is **null** if symbol is **null**.
    ///
    /// - Parameters:
    ///   - symbol: The specified symbol
    /// - Returns: Returns base symbol without exchange code and attributes.
    public static func getBaseSymbol(_ symbol: String?) -> String? {
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

    /// Returns value of the attribute with the specified key.
    /// The result is **null** if attribute with the specified key is not found.
    /// The result is **null** if symbol is **null**.
    ///
    /// - Parameters:
    ///   - symbol: The  symbol
    ///   - key: The attribute key
    /// - Returns: Returns value of the attribute with the specified key
    /// - Throws: ``ArgumentException/argumentNil``
    public static func getAttributeStringByKey(_ symbol: String?, _ key: String?) throws -> String? {
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
    /// Removes one attribute with the specified key while leaving exchange code and other attributes intact.
    /// The result is **null** if symbol is **null**.
    ///
    /// - Parameters:
    ///   - symbol: The old  symbol
    ///   - key: The attribute key
    /// - Returns: Returns new symbol without the specified key and everything else from the old symbol
    /// - Throws: ``ArgumentException/argumentNil``
    public static func removeAttributeStringByKey(_ symbol: String?,
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

    /// Changes value of one attribute value while leaving exchange code and other attributes intact.
    /// The **null** symbol is interpreted as empty one by this method.
    ///
    /// - Parameters:
    ///   - symbol: The old  symbol
    ///   - key: The attribute key
    ///   - value: The attribute value
    /// - Returns: Returns new symbol with key attribute with the specified value and everything else from the old symbol.
    /// - Throws: ``ArgumentException/argumentNil``
    public static func changeAttributeStringByKey(_ symbol: String?,
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
                return """
\(symbol)\
\(Separtors.open.rawValue)\
\(key)\
\(Separtors.value.rawValue)\
\(value)\
\(Separtors.close.rawValue)
"""
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
            return """
\(symbol)\
\(Separtors.open.rawValue)\
\(key)\
\(Separtors.value.rawValue)\
\(value)\
\(Separtors.close.rawValue)
"""
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
                        added = true
                        index += key.length + value.length + 2
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
            } else {
                print("NULLL")
            }
        }
        return added ? symbol : (symbol[0..<index-1] +
                                 "\(Separtors.separator.rawValue)\(key)\(Separtors.value.rawValue)\(value)" +
                                 symbol[index-1..<symbol.length])
    }

    /// Returns exchange code of the specified symbol or **'\0'** if none is defined.
    /// The result is **'\0'** if symbol is **null**.
    ///
    /// - Parameters:
    ///   - symbol: The specified  symbol
    /// - Returns: Returns exchange code of the specified symbol or **'\0'** if none is defined.
    public static func getExchangeCode(_ symbol: String?) -> Character {
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
    /// Checks if the specified symbol has the exchange code specification.
    /// The result is **false** if symbol is **null**.
    ///
    /// - Parameters:
    ///   - symbol: The specified  symbol
    /// - Returns: Returns **true** is the specified symbol has the exchange code specification
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
