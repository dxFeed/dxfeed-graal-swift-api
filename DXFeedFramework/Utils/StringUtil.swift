//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
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

    static func random(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
