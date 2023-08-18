//
//  TimeUtil.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 18.08.23.
//

import Foundation

class TimeUtil {
    public static let second =  Long(1000)
    public static let minute =  60 * Long(1000)

    public static func getMillisFromTime(timeMillis: Long) -> Int {
        return Int(MathUtil.floorMod(timeMillis, second))
    }
}
