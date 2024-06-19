//
//  Quote+Access.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 15.06.23.
//

import Foundation

extension Quote {
    public var time: Int64 {
        (MathUtil.floorDiv(xValue: max(bidTime, askTime), yValue: 1000) * 1000) + (Int64(timeMillisSequence) >> 22)
    }
}
