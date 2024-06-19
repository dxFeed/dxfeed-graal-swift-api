//
//  NativeSchedule.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 13.09.23.
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
        let day = try ErrorCheck.nativeCall(thread, dxfg_Schedule_getDayByTime(thread, schedule, time))
        defer {
            _ = try? ErrorCheck.nativeCall(thread, dxfg_JavaObjectHandler_release(thread, &(day.pointee.handler)))
        }
        return try createDay(thread, day)
    }

    public func getDayById(dayId: Int32) throws -> ScheduleDay {
        let thread = currentThread()
        let day = try ErrorCheck.nativeCall(thread, dxfg_Schedule_getDayById(thread, schedule, dayId))
        defer {
            _ = try? ErrorCheck.nativeCall(thread, dxfg_JavaObjectHandler_release(thread, &(day.pointee.handler)))
        }
        return try createDay(thread, day)
    }

    private func createDay(_ thread: OpaquePointer?,
                           _ day: UnsafeMutablePointer<dxfg_day_t>) throws -> ScheduleDay {
        let scheduleDay = ScheduleDay()
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
        let sessions = try ErrorCheck.nativeCall(thread, dxfg_Day_getSessions(thread, day))
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
        let type = dxfg_session_type_t(UInt32(nativeType))
        let session = ScheduleSession(native: NativeSession(native: session),
                                      nativeSchedule: self,
                                      startTime: start,
                                      endTime: end,
                                      type: ScheduleSessionType.getValueFromNative(type))
        return session
    }

    internal func getNextDay(after day: ScheduleDay, filter: DayFilter ) throws -> ScheduleDay? {
        let qdValue = filter.toQDValue()
        let thread = currentThread()
        let filter = try ErrorCheck.nativeCall(thread, dxfg_DayFilter_getInstance(thread, qdValue))
        let currentDay = try ErrorCheck.nativeCall(thread, dxfg_Schedule_getDayById(thread, schedule, day.dayId))
        let nextDay = try ErrorCheck.nativeCall(thread, dxfg_Day_getNextDay(thread, currentDay, filter))
        let day = try? createDay(thread, nextDay)
        try ErrorCheck.nativeCall(thread, dxfg_JavaObjectHandler_release(thread, &(nextDay.pointee.handler)))
        return day
    }

    internal func getPrevtDay(before day: ScheduleDay, filter: DayFilter ) throws -> ScheduleDay? {
        let qdValue = filter.toQDValue()
        let thread = currentThread()
        let filter = try ErrorCheck.nativeCall(thread, dxfg_DayFilter_getInstance(thread, qdValue))
        defer {
            _ = try? ErrorCheck.nativeCall(thread, dxfg_JavaObjectHandler_release(thread, &(filter.pointee.handler)))
        }
        let currentDay = try ErrorCheck.nativeCall(thread, dxfg_Schedule_getDayById(thread, schedule, day.dayId))
        defer {
            _ = try? ErrorCheck.nativeCall(thread, dxfg_JavaObjectHandler_release(thread, &(currentDay.pointee.handler)))
        }
        let prevDay = try ErrorCheck.nativeCall(thread, dxfg_Day_getPrevDay(thread, currentDay, filter))
        defer {
            _ = try? ErrorCheck.nativeCall(thread, dxfg_JavaObjectHandler_release(thread, &(prevDay.pointee.handler)))
        }
        let day = try? createDay(thread, prevDay)
        return day
    }

    internal func getNextSession(after session: ScheduleSession, filter: SessionFilter ) throws -> ScheduleSession? {
        let qdValue = filter.toQDValue()
        let thread = currentThread()
        let filter = try ErrorCheck.nativeCall(thread, dxfg_SessionFilter_getInstance(thread, qdValue))
        defer {
            _ = try? ErrorCheck.nativeCall(thread, dxfg_JavaObjectHandler_release(thread, &(filter.pointee.handler)))
        }
        let currentSession = session.native.native
        let nextSession = try ErrorCheck.nativeCall(thread,
                                                    dxfg_Session_getNextSession(thread, currentSession, filter))
        let session = try createSession(thread, session: nextSession)
        return session
    }

    internal func getPrevtSession(before session: ScheduleSession, filter: SessionFilter ) throws -> ScheduleSession? {
        let qdValue = filter.toQDValue()
        let thread = currentThread()
        let filter = try ErrorCheck.nativeCall(thread, dxfg_SessionFilter_getInstance(thread, qdValue))
        defer {
            _ = try? ErrorCheck.nativeCall(thread, dxfg_JavaObjectHandler_release(thread, &(filter.pointee.handler)))
        }
        let currentSession = session.native.native
        let nextSession = try ErrorCheck.nativeCall(thread,
                                                    dxfg_Session_getPrevSession(thread, currentSession, filter))
        let session = try createSession(thread, session: nextSession)
        return session
    }
}
