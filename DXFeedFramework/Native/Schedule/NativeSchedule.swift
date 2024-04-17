//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
@_implementationOnly import graal_api

/// Native wrapper over the Java com.dxfeed.schedule.Schedule class.
class NativeSchedule {
    let schedule: UnsafeMutablePointer<dxfg_schedule_t>?

    init(schedule: UnsafeMutablePointer<dxfg_schedule_t>?) {
        self.schedule = schedule
    }

    convenience init(scheduleDefinition: String) throws {
        let thread = currentThread()
        let schedule = try ErrorCheck.nativeCall(thread,
                                                 dxfg_Schedule_getInstance2(thread, scheduleDefinition.toCStringRef()))
        self.init(schedule: schedule)
    }

    convenience init(instrumentProfile: InstrumentProfile) throws {
        let mapper = InstrumentProfileMapper()
        let native = mapper.toNative(instrumentProfile: instrumentProfile)
        let thread = currentThread()
        let schedule = try ErrorCheck.nativeCall(thread,
                                                 dxfg_Schedule_getInstance(thread,
                                                                           native))
        mapper.releaseNative(native: native)
        self.init(schedule: schedule)
    }

    convenience init(instrumentProfile: InstrumentProfile, venue: String) throws {
        let mapper = InstrumentProfileMapper()
        let native = mapper.toNative(instrumentProfile: instrumentProfile)
        let thread = currentThread()
        let schedule = try ErrorCheck.nativeCall(
            thread, dxfg_Schedule_getInstance3(thread,
                                               native,
                                               venue.toCStringRef()))
        mapper.releaseNative(native: native)
        self.init(schedule: schedule)
    }

    deinit {
        if let schgedule = schedule {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread,
                                           dxfg_JavaObjectHandler_release(thread,
                                                                          &(schgedule.pointee.handler)))
        }
    }

    public static func getTradingVenues(profile: InstrumentProfile ) throws -> [String] {
        let thread = currentThread()
        let mapper = InstrumentProfileMapper()
        let native = mapper.toNative(instrumentProfile: profile)
        var resultVenues = [String]()
        if let result = try? ErrorCheck.nativeCall(thread, dxfg_Schedule_getTradingVenues(thread, native)) {
            for index in 0..<result.pointee.size {
                let venue = result.pointee.elements[Int(index)]
                resultVenues.append(String(pointee: venue))
            }
            _ = try? ErrorCheck.nativeCall(thread,
                                           dxfg_CList_String_release(thread,
                                                                     result))
        }
        return resultVenues
    }

    public func getName() throws -> String {
        let thread = currentThread()
        let name = try ErrorCheck.nativeCall(thread, dxfg_Schedule_getName(thread, schedule))
        return String(pointee: name)
    }

    public func getTimeZone() throws -> String {
        let thread = currentThread()
        let timeZone = try ErrorCheck.nativeCall(thread, dxfg_Schedule_getTimeZone(thread, schedule))
        return String(pointee: timeZone)
    }

    public func getTimeZoneId() throws -> String {
        let thread = currentThread()
        let timeZone = try ErrorCheck.nativeCall(thread, dxfg_Schedule_getTimeZone_getID(thread, schedule))
        return String(pointee: timeZone)
    }

    public func getDayByTime(time: Long) throws -> ScheduleDay {
        let thread = currentThread()
        let day = try ErrorCheck.nativeCall(thread, dxfg_Schedule_getDayByTime(thread, schedule, time)).value()
        return try createDay(thread, day)
    }

    public func getDayById(dayId: Int32) throws -> ScheduleDay {
        let thread = currentThread()
        let day = try ErrorCheck.nativeCall(thread, dxfg_Schedule_getDayById(thread, schedule, dayId)).value()
        return try createDay(thread, day)
    }

    public func getDayByYearMonthDay(yearMonthDay: Int32) throws -> ScheduleDay {
        let thread = currentThread()
        let day = try ErrorCheck.nativeCall(thread, dxfg_Schedule_getDayByYearMonthDay(thread, schedule, yearMonthDay)).value()
        return try createDay(thread, day)
    }

    private func createDay(_ thread: OpaquePointer?,
                           _ day: UnsafeMutablePointer<dxfg_day_t>) throws -> ScheduleDay {
        let scheduleDay = ScheduleDay()
        scheduleDay.native = NativeDay(native: day)
        scheduleDay.nativeSchedule = self
        scheduleDay.dayId = try ErrorCheck.nativeCall(thread, dxfg_Day_getDayId(thread, day))
        scheduleDay.yearMonthDay = try ErrorCheck.nativeCall(thread, dxfg_Day_getYearMonthDay(thread, day))
        scheduleDay.year = try ErrorCheck.nativeCall(thread, dxfg_Day_getYear(thread, day))
        scheduleDay.monthOfYear = try ErrorCheck.nativeCall(thread, dxfg_Day_getMonthOfYear(thread, day))
        scheduleDay.dayOfMonth = try ErrorCheck.nativeCall(thread, dxfg_Day_getDayOfMonth(thread, day))
        scheduleDay.dayOfWeek = try ErrorCheck.nativeCall(thread, dxfg_Day_getDayOfWeek(thread, day))
        scheduleDay.holiday = try ErrorCheck.nativeCall(thread, dxfg_Day_isHoliday(thread, day))
        scheduleDay.shortDay = try ErrorCheck.nativeCall(thread, dxfg_Day_isShortDay(thread, day))
        scheduleDay.resetTime = try ErrorCheck.nativeCall(thread, dxfg_Day_getResetTime(thread, day))
        scheduleDay.trading = try ErrorCheck.nativeCall(thread, dxfg_Day_isTrading(thread, day))
        scheduleDay.startTime = try ErrorCheck.nativeCall(thread, dxfg_Day_getStartTime(thread, day))
        scheduleDay.endTime = try ErrorCheck.nativeCall(thread, dxfg_Day_getEndTime(thread, day))
        let sessions = try ErrorCheck.nativeCall(thread, dxfg_Day_getSessions(thread, day)).value()
        let count = sessions.pointee.size
        for index in 0..<Int(count) {
            if let element = sessions.pointee.elements[index] {
                let session = try createSession(thread,
                                                session: element)
                scheduleDay.sessions.append(session)
            }
        }
        return scheduleDay
    }

    private func createSession(_ thread: OpaquePointer?,
                               session: UnsafeMutablePointer<dxfg_session_t>) throws -> ScheduleSession {
        let start = try ErrorCheck.nativeCall(thread, dxfg_Session_getStartTime(thread, session))
        let end = try ErrorCheck.nativeCall(thread, dxfg_Session_getEndTime(thread, session))
        let nativeType = try ErrorCheck.nativeCall(thread, dxfg_Session_getType(thread, session))
        let isTraiding = try ErrorCheck.nativeCall(thread, dxfg_Session_isTrading(thread, session))
        let day = try ErrorCheck.nativeCall(thread, dxfg_Session_getDay(thread, session)).value()
        defer {
            _ = try? ErrorCheck.nativeCall(thread, dxfg_JavaObjectHandler_release(thread, &(day.pointee.handler)))
        }
        let yearMonthDay = try ErrorCheck.nativeCall(thread, dxfg_Day_getYearMonthDay(thread, day))
        let type = dxfg_session_type_t(UInt32(nativeType))
        let session = ScheduleSession(native: NativeSession(native: session),
                                      nativeSchedule: self,
                                      startTime: start,
                                      endTime: end,
                                      type: ScheduleSessionType.getValueFromNative(type),
                                      yearMonthDay: yearMonthDay,
                                      isTrading: isTraiding == 1)
        return session
    }

    internal func getNextDay(after day: ScheduleDay, filter: DayFilter) throws -> ScheduleDay? {
        try getDay(for: day, filter: filter) { thread, nativeDay, filter in
            try ErrorCheck.nativeCall(thread, dxfg_Day_getNextDay(thread, nativeDay, filter))
        }
    }

    internal func getPrevtDay(before day: ScheduleDay, filter: DayFilter ) throws -> ScheduleDay? {
        try getDay(for: day, filter: filter) { thread, nativeDay, filter in
            try ErrorCheck.nativeCall(thread, dxfg_Day_getPrevDay(thread, nativeDay, filter))
        }
    }

    typealias GetDayExecutor =
    (OpaquePointer?,
     UnsafeMutablePointer<dxfg_day_t>?,
     UnsafeMutablePointer<dxfg_day_filter_t>) throws -> UnsafeMutablePointer<dxfg_day_t>

    private func getDay(for day: ScheduleDay,
                        filter: DayFilter,
                        executor: GetDayExecutor) throws -> ScheduleDay? {
        let qdValue = filter.toQDValue()
        let thread = currentThread()
        let filter = try ErrorCheck.nativeCall(thread, dxfg_DayFilter_getInstance(thread, qdValue)).value()
        defer {
            _ = try? ErrorCheck.nativeCall(thread, dxfg_JavaObjectHandler_release(thread, &(filter.pointee.handler)))
        }
        let nextDay = try executor(thread, day.native?.native, filter)
        let day = try? createDay(thread, nextDay)
        return day
    }

    internal func getNextSession(after session: ScheduleSession,
                                 filter: SessionFilter) throws -> ScheduleSession? {
        try getSession(for: session, filter: filter, executor: { thread, session, filter in
            try ErrorCheck.nativeCall(thread, dxfg_Session_getNextSession(thread, session, filter))
        })
    }

    internal func getPrevtSession(before session: ScheduleSession, filter: SessionFilter ) throws -> ScheduleSession? {
        try getSession(for: session, filter: filter, executor: { thread, session, filter in
            try ErrorCheck.nativeCall(thread, dxfg_Session_getPrevSession(thread, session, filter))
        })
    }

    typealias GetSessionyExecutor =
    (OpaquePointer?,
     UnsafeMutablePointer<dxfg_session_t>?,
     UnsafeMutablePointer<dxfg_session_filter_t>) throws -> UnsafeMutablePointer<dxfg_session_t>

    private func getSession(for session: ScheduleSession,
                            filter: SessionFilter,
                            executor: GetSessionyExecutor) throws -> ScheduleSession? {
        let qdValue = filter.toQDValue()
        let thread = currentThread()
        let filter = try ErrorCheck.nativeCall(thread, dxfg_SessionFilter_getInstance(thread, qdValue)).value()
        defer {
            _ = try? ErrorCheck.nativeCall(thread, dxfg_JavaObjectHandler_release(thread, &(filter.pointee.handler)))
        }
        let nextSession = try executor(thread, session.native.native, filter)
        let session = try createSession(thread, session: nextSession)
        return session
    }

    public func getSessionByTime(time: Long) throws -> ScheduleSession {
        let thread = currentThread()
        let nextSession = try ErrorCheck.nativeCall(thread, dxfg_Schedule_getSessionByTime(thread, schedule, time)).value()
        let session = try createSession(thread, session: nextSession)
        return session
    }

    public func getNearestSessionByTime(time: Long, filter: SessionFilter) throws -> ScheduleSession {
        let qdValue = filter.toQDValue()
        let thread = currentThread()
        let filter = try ErrorCheck.nativeCall(thread, dxfg_SessionFilter_getInstance(thread, qdValue)).value()
        defer {
            _ = try? ErrorCheck.nativeCall(thread, dxfg_JavaObjectHandler_release(thread, &(filter.pointee.handler)))
        }
        let nextSession = try ErrorCheck.nativeCall(thread,
                                                    dxfg_Schedule_getNearestSessionByTime(thread,
                                                                                          schedule,
                                                                                          time,
                                                                                          filter)).value()
        let session = try createSession(thread, session: nextSession)
        return session
    }

    public static func setDefaults(_ data: Data) throws {
        let thread = currentThread()
        _ = try data.withUnsafeBytes({ pointer in
            _ = try ErrorCheck.nativeCall(thread, dxfg_Schedule_setDefaults(thread,
                                                                            pointer.baseAddress,
                                                                            Int32(data.count)))
        })
    }

    public static func downloadDefaults(_ url: String) throws {
        let thread = currentThread()
        _ = try ErrorCheck.nativeCall(thread, dxfg_Schedule_downloadDefaults(thread,
                                                                         url.toCStringRef()))
    }
}
