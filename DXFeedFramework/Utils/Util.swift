//
//  Util.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 18.08.23.
//

import Foundation

class Util {
    static func getBits(flags: Int, mask: Int, shift: Int) -> Int {
        return (flags >> shift) & mask
    }

    static func setBits(flags: Int, mask: Int, shift: Int, bits: Int) -> Int {
        return (flags & ~(mask << shift)) | ((bits & mask) << shift)
    }
}
