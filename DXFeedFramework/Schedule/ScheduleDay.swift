//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

/// Day represents a continuous period of time approximately 24 hours long.
///
/// The day is aligned to the start and the end of business activities of a certain business entity or business process.
/// For example, the day may be aligned to a trading schedule of a particular instrument on an exchange.
/// Thus, different days may start and end at various local times depending on the related trading schedules.
///
/// The length of the day depends on the trading schedule and other circumstances. For example, it is possible
/// that day for Monday is longer than 24 hours because it includes part of Sunday; consequently, the day for
/// Sunday will be shorter than 24 hours to avoid overlapping with Monday.
///
/// Days do not overlap with each other - rather they form consecutive chain of adjacent periods of time that
/// cover entire time scale. The point on a border line is considered to belong to following day that starts there.
///
/// Each day consists of sessions that cover entire duration of the day. If day contains at least one trading
/// session (i.e. session within which trading activity is allowed), then the day is considered trading day.
/// Otherwise the day is considered non-trading day (e.g. weekend or holiday).
///
/// Day may contain sessions with zero duration - e.g. indices that post value once a day.
/// Such sessions can be of any appropriate type, trading or non-trading.
/// Day may have zero duration as well - e.g. when all time within it is transferred to other days.
public class ScheduleDay {
    /// Returns native ref
    internal var native: NativeDay?
    /// Returns schedule to which this day belongs.
    internal var nativeSchedule: NativeSchedule?
    /// Number of this day since January 1, 1970 (that day has identifier of 0 and previous days have negative identifiers).
    public internal(set) var dayId: Int32 = 0
    /// Returns year, month and day numbers decimally packed in the following way:
    /// YearMonthDay = year * 10000 + month * 100 + day
    /// For example, September 28, 1977 has value 19770928.
    public internal(set) var yearMonthDay: Int32 = 0
    /// Returns calendar year - i.e. it returns 1977 for the year 1977.
    public internal(set) var year: Int32 = 0
    /// Returns calendar month number in the year starting with 1=January and ending with 12=December.
    public internal(set) var monthOfYear: Int32 = 0
    /// Returns ordinal day number in the month starting with 1 for the first day of month.
    public internal(set) var dayOfMonth: Int32 = 0
    /// Returns ordinal day number in the week starting with 1=Monday and ending with 7=Sunday.
    public internal(set) var dayOfWeek: Int32 = 0
    /// Returns true if this day is an exchange holiday.
    /// Usually there are no trading takes place on an exchange holiday.
    public internal(set) var holiday: Int32 = 0
    /// Returns true if this day is a short day.
    /// Usually trading stops earlier on a short day.
    public internal(set) var shortDay: Int32 = 0
    /// Returns true if trading activity is allowed within this day.
    /// Positive result assumes that day has at least one trading session.
    public internal(set) var resetTime: Int64 = 0
    /// Returns true if this day is a short day.
    /// Usually trading stops earlier on a short day.
    public internal(set) var trading: Int32 = 0
    /// Returns start time of this day (inclusive).
    public internal(set) var startTime: Int64 = 0
    /// Returns end time of this day (exclusive).
    public internal(set) var endTime: Int64 = 0
    /// Returns list of sessions that constitute this day.
    /// The list is ordered according to natural order of sessions - how they occur one after another.
    public internal(set) var sessions = [ScheduleSession]()
}

extension ScheduleDay {
    public func getPrevious(filter: DayFilter) throws -> ScheduleDay? {
        return try nativeSchedule?.getPrevtDay(before: self, filter: filter)
    }

    public func getNext(filter: DayFilter) throws -> ScheduleDay? {
        return try nativeSchedule?.getNextDay(after: self, filter: filter)
    }
}

extension ScheduleDay: Equatable {
    public static func == (lhs: ScheduleDay, rhs: ScheduleDay) -> Bool {
        return lhs === rhs || lhs.dayId == rhs.dayId
    }
}
