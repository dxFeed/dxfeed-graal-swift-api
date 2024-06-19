//
//  Candle+Access.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 17.07.23.
//

import Foundation

extension Candle {
    public var time: Int64 {
        Int64(((self.index >> 32) * 1000) + ((self.index >> 22) & 0x3ff))
    }
}
