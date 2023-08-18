//
//  StringUtil.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 18.08.23.
//

import Foundation

class StringUtil {
    public static func encodeChar(char: Int16) -> String {
        if char >= 32 && char <= 126 {
            return String(UnicodeScalar(UInt8(char)))
        }
        let value = (String(format: "%02X", Int(char) + 65536).substring(fromIndex: 1))
        return char == 0 ? "\0" : "\\u" + value
    }
}
