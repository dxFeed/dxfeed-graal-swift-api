//
//  DayUtil.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 18.08.23.
//

import Foundation

class DayUtil {
    public static func getYearMonthDayByDayId(_ dayId: Int) -> Int {
        let jValue = dayId + 2472632 // this shifts the epoch back to astronomical year -4800
        let gValue = MathUtil.div(jValue, 146097)
        let dgValue = jValue - gValue * 146097
        let cValue = (dgValue / 36524 + 1) * 3 / 4
        let dcValue = dgValue - cValue * 36524
        let bValue = dcValue / 1461
        let dbValue = dcValue - bValue * 1461
        let aValue = (dbValue / 365 + 1) * 3 / 4
        let daValue = dbValue - aValue * 365
        // this is the integer number of full years elapsed since March 1, 4801 BC at 00:00 UTC
        let yValue = gValue * 400 + cValue * 100 + bValue * 4 + aValue
        // this is the integer number of full months elapsed since the last March 1 at 00:00 UTC
        let mValue = (daValue * 5 + 308) / 153 - 2
        // this is the number of days elapsed since day 1 of the month at 00:00 UTC
        let dValue = daValue - (mValue + 4) * 153 / 5 + 122
        let yyyyValue = yValue - 4800 + (mValue + 2) / 12
        let mmValue = (mValue + 2) % 12 + 1
        let ddValue = dValue + 1
        let yyyymmddValue = abs(yyyyValue) * 10000 + mmValue * 100 + ddValue
        return Int(yyyyValue >= 0 ? yyyymmddValue : -yyyymmddValue)
    }
}
