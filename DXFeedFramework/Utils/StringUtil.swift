//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

public class StringUtil {
    static func encodeChar(char: Int16) -> String {
        if char >= 32 && char <= 126 {
            return String(UnicodeScalar(UInt8(char)))
        }
        var value = String(format: "%2X", Int(char))
        (0..<4 - value.count).forEach { _ in
            value = "0" + value
        }
        let res = char == 0 ? "\\0" : "\\u" + value
        return res
    }

    public static func decodeChar(_ string: String) -> Int16 {
        if string == "\\0" {
            return 0
        }
        if string.hasPrefix("\\u") {
            let str = string.dropFirst("\\u".count)
            return Int16(str, radix: 16) ?? 0
        } else {
            return Int16(UnicodeScalar(string)?.value ?? 0)
        }
    }

    static func checkChar(char: Character, mask: Int, name: String) throws {
        guard let value = char.unicodeScalars.first?.value else {
            throw ArgumentException.exception("Invalid \(name): \(char)")
        }
        if (Int(value) & ~mask) != 0 {
            throw ArgumentException.exception("Invalid \(name): \(char)")
        }
    }

    static func random(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
}
