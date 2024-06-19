//
//  MathUtil.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 15.06.23.
//

import Foundation

class MathUtil {
    static func floorDiv(_ xValue: Long, _ yValue: Long) -> Long {
        var rValue = xValue / yValue
        // If the signs are different and modulo not zero, round down.
        if (xValue ^ yValue) < 0 && rValue * yValue != xValue {
            rValue -= 1
        }
        return rValue
    }

    static func floorMod(_ xValue: Long, _ yValue: Long) -> Long {
        return xValue - (floorDiv(xValue, yValue) * yValue)
    }
}
