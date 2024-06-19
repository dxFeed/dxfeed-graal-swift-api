//
//  TimeAndSale+Access.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 14.06.23.
//

import Foundation

extension TimeAndSale {
    public var time: UInt64 {
        get { UInt64(((self.index >> 32) * 1000) + ((self.index >> 22) & 0x3ff)) }
        set {}
    }
}
