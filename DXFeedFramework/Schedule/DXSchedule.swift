//
//  DXSchedule.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 13.09.23.
//

import Foundation

public class DXSchedule {
    let native: NativeSchedule

    private init(native: NativeSchedule) {
        self.native = native
    }

    convenience init(scheduleDefinition: String) throws {
        let native = try NativeSchedule(scheduleDefinition: scheduleDefinition)
        self.init(native: native)
    }

    convenience init(instrumentProfile: InstrumentProfile) throws {
        let native = try NativeSchedule(instrumentProfile: instrumentProfile)
        self.init(native: native)
    }

    convenience init(instrumentProfile: InstrumentProfile, venue: String) throws {
        let native = try NativeSchedule(instrumentProfile: instrumentProfile, venue: venue)
        self.init(native: native)
    }

    public func getName() throws -> String {
        return try native.getName()
    }

    public func getTimeZone() throws -> String {
        return try native.getTimeZone()
    }

    public func getDayByTime(time: Long) throws -> ScheduleDay {
        return try native.getDayByTime(time: time)
    }

    public func getDayById(day: Int32) throws -> ScheduleDay {
        return try native.getDayById(dayId: day)
    }
}
