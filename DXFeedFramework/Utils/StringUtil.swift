//
//  StringUtil.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 18.08.23.
//

import Foundation

class StringUtil {
    static func encodeChar(char: Int16) -> String {
        if char >= 32 && char <= 126 {
            return String(UnicodeScalar(UInt8(char)))
        }
        let value = (String(format: "%02X", Int(char) + 65536).substring(fromIndex: 1))
        let res = char == 0 ? "\\0" : "\\u" + value
        return res
    }

    static func checkChar(char: Character, mask: Int, name: String) throws {
        guard let value = char.unicodeScalars.first?.value else {
            throw ArgumentException.exception("Invalid \(name): \(char)")
        }
        if (Int(value) & ~mask) != 0 {
            throw ArgumentException.exception("Invalid \(name): \(char)")
        }
    }
}
