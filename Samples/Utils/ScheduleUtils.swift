//
//  ScheduleUtils.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 10.10.23.
//

import Foundation
import DXFeedFramework

class ScheduleUtils {
    static func findNext5Days(_ profile: InstrumentProfile, time: Long, separator: String) throws -> String {
        let schedule = try DXSchedule(instrumentProfile: profile)
        var day: ScheduleDay? = try schedule.getDayByTime(time: time)
        var dates = [String]()
        dates.append("5 next holidays for \(profile.symbol):")
        for _ in 0..<5 {
            day = try day?.getNext(filter: DayFilter.holiday)
            dates.append("\(day?.yearMonthDay ?? 0)")
        }
        return dates.joined(separator: separator)
    }

    static func getSessions(_ profile: InstrumentProfile, time: Long) throws -> String {
        let schedule = try DXSchedule(instrumentProfile: profile)
        let session = try schedule.getSessionByTime(time: time)
        let nextTradingSession = session.isTrading ? session : try session.getNext(filter: .trading)
        let nearestSession = try schedule.getNearestSessionByTime(time: time, filter: .trading)

        func sessionDescription(_ session: ScheduleSession?) -> String {
            guard let session = session else {
                return ""
            }
            return session.toString()
        }
        return """
Current session for \(profile.symbol): \(sessionDescription(session))
Next trading session for \(profile.symbol): \(sessionDescription(nextTradingSession))
Nearest trading session for \(profile.symbol): \(sessionDescription(nearestSession))
"""
    }
}
