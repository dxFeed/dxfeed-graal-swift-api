//
//  Double+Ext.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 09.08.23.
//

import Foundation

infix operator ~==
infix operator ~<=
infix operator ~>=

extension Double {
    static func ~== (lhs: Double, rhs: Double) -> Bool {
        // If we add even a single zero more,
        // our Decimal test would fail.
        fabs(lhs - rhs) < 0.000000000001
    }

    static func ~<= (lhs: Double, rhs: Double) -> Bool {
        (lhs < rhs) || (lhs ~== rhs)
    }

    static func ~>= (lhs: Double, rhs: Double) -> Bool {
        (lhs > rhs) || (lhs ~== rhs)
    }
}

extension Double {
    public static let expBitMask = Long(0x7FF0000000000000)
    public static let signIfBitMask = Long(0x000FFFFFFFFFFFFF)

    public static func doubleToRawLongBits(_ num: Double) -> Long {
        var num = num
        var bits: Int64 = 0
        memcpy(&bits, &num, MemoryLayout.size(ofValue: bits))
        return bits
    }

    public static func longBitsToDouble(_ bits: Long) -> Double {
        var bits = bits
        var result: Double = 0
        memcpy(&result, &bits, MemoryLayout.size(ofValue: result))
        return result
    }

    public static func doubleToLongBits(value: Double) -> Long {
        var result = doubleToRawLongBits(value)
        // Check for NaN based on values of bit fields, maximum
        // exponent and nonzero significand.
        if ((result & expBitMask) == expBitMask) && (result & signIfBitMask) != 0 {
            result = 0x7ff8000000000000
        }
        return result
    }
}
