//
//  MathUtil.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 15.06.23.
//

import Foundation

class MathUtil {
    static func floorDiv(xValue: Int64, yValue: Int64) -> Int64 {
        var rValue = xValue / yValue
        // If the signs are different and modulo not zero, round down.
        if (xValue ^ yValue) < 0 && rValue * yValue != xValue {
            rValue -= 1
        }
        return rValue
    }
}
