//
//  DXSchedule.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 13.09.23.
//

import Foundation

/// Schedule class provides API to retrieve and explore trading schedules of different exchanges
/// and different classes of financial instruments.
///
/// Each instance of schedule covers separate trading schedule
/// of some class of instruments, i.e. NYSE stock trading schedule or CME corn futures trading schedule.
/// Each schedule splits entire time scale into separate ``ScheduleDay`` that are aligned to the specific
/// trading hours of covered trading schedule.
public class DXSchedule {
    let native: NativeSchedule

    internal init(native: NativeSchedule) {
        self.native = native
    }
    /// Returns default schedule instance for specified schedule definition.
    ///
    /// - Parameters:
    ///    - scheduleDefinition: schedule definition of requested schedule
    /// - Throws: GraalException. Rethrows exception from Java.recore
    public convenience init(scheduleDefinition: String) throws {
        let native = try NativeSchedule(scheduleDefinition: scheduleDefinition)
        self.init(native: native)
    }

    /// Returns default schedule instance for specified instrument profile.
    ///
    /// - Parameters:
    ///    - instrumentProfile: instrument profile those schedule is requested
    /// - Throws: GraalException. Rethrows exception from Java.recore
    public convenience init(instrumentProfile: InstrumentProfile) throws {
        let native = try NativeSchedule(instrumentProfile: instrumentProfile)
        self.init(native: native)
    }

    /// Returns schedule instance for specified instrument profile and trading venue.
    ///
    /// - Parameters:
    ///    - instrumentProfile: instrument profile those schedule is requested
    ///    - venue: trading venue those schedule is requested
    /// - Throws: GraalException. Rethrows exception from Java.recore
    public convenience init(instrumentProfile: InstrumentProfile, venue: String) throws {
        let native = try NativeSchedule(instrumentProfile: instrumentProfile, venue: venue)
        self.init(native: native)
    }

    /// Returns day that contains specified time.
    ///
    /// - Throws: GraalException. Rethrows exception from Java.recore
    public func getName() throws -> String {
        return try native.getName()
    }

    /// Returns time zone name in which this schedule is defined.
    ///
    /// - Throws: GraalException. Rethrows exception from Java.recore
    public func getTimeZone() throws -> String {
        return try native.getTimeZone()
    }

    /// Returns time zone id in which this schedule is defined.
    ///
    /// - Throws: GraalException. Rethrows exception from Java.recore
    public func getTimeZoneId() throws -> String {
        return try native.getTimeZoneId()
    }

    /// Returns day that contains specified time.
    ///
    /// This method will throw exception if specified time
    /// falls outside of valid date range from 0001-01-02 to 9999-12-30.
    /// - Parameters:
    ///    - time: the time to search for
    /// - Throws: GraalException. Rethrows exception from Java.recore
    public func getDayByTime(time: Long) throws -> ScheduleDay {
        let day = try native.getDayByTime(time: time)
        return day
    }

    /// Returns day for specified day identifier.
    ///
    /// This method will throw exception if specified day identifier
    /// falls outside of valid date range from 0001-01-02 to 9999-12-30.
    /// - Parameters:
    ///    - day: identifier to search for
    /// - Throws: GraalException. Rethrows exception from Java.recore
    public func getDayById(day: Int32) throws -> ScheduleDay {
        let day = try native.getDayById(dayId: day)
        return day
    }

    /// Returns session that contains specified time.
    ///
    /// This method will throw exception
    /// if specified time falls outside of valid date range from 0001-01-02 to 9999-12-30.
    ///
    /// - Parameters:
    ///   - time:  time the time to search for
    /// - Returns: session that contains specified time
    /// - Throws: GraalException. Rethrows exception from Java.
    public func getSessionByTime(time: Long) throws -> ScheduleSession {
        return try native.getSessionByTime(time: time)
    }

    /// Returns session that is nearest to the specified time and that is accepted by specified filter.
    ///
    /// This method will throw exception  if specified time
    /// falls outside of valid date range from 0001-01-02 to 9999-12-30.
    /// If no sessions acceptable by specified filter are found within one year this method will throw exception
    ///
    /// To find nearest trading session of any type use this code:
    /// session = schedule.getNearestSessionByTime(time, SessionFilter.TRADING);
    /// To find nearest regular trading session use this code:
    /// session = schedule.getNearestSessionByTime(time, SessionFilter.REGULAR);
    ///
    /// - Parameters:
    ///   - time:  time the time to search for
    ///   - filter: the filter to test sessions
    /// - Returns: session that contains specified time
    /// - Throws: GraalException. Rethrows exception from Java.
    public func getNearestSessionByTime(time: Long, filter: SessionFilter) throws -> ScheduleSession {
        return try native.getNearestSessionByTime(time: time, filter: filter)
    }
}
