//
//  BitUtil.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 18.08.23.
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
