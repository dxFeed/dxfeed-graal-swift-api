//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

class BitUtil<T> where T: BinaryInteger {
    static func getBits(flags: T, mask: T, shift: T) -> T {
        return (flags >> shift) & mask
    }

    static func setBits(flags: T, mask: T, shift: T, bits: T) -> T {
        return (flags & ~(mask << shift)) | ((bits & mask) << shift)
    }
}

infix operator >>> : BitwiseShiftPrecedence

func >>> (lhs: Int64, rhs: Int64) -> Int64 {
    return Int64(bitPattern: UInt64(bitPattern: lhs) >> UInt64(rhs))
}

