//
//  TimeNanosUtil.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 18.08.23.
//

import Foundation

class TimeNanosUtil {
    private static let NanosInMillis = Long(1_000_000)

    static func getNanosFromMillisAndNanoPart(_ timeMillis: Long, _ timeNanoPart: Int32) -> Long {
        return (timeMillis * NanosInMillis) + Long(timeNanoPart)
    }

    static func getMillisFromNanos(_ timeNanos: Long) -> Long {
        return MathUtil.floorDiv(timeNanos, NanosInMillis)
    }

    static func getNanoPartFromNanos(_ timeNanos: Long) -> Long {
        return MathUtil.floorMod(timeNanos, NanosInMillis)
    }

}
