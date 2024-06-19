//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
