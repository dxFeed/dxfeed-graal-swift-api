//
//  ScheduleSession.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 13.09.23.
//

import Foundation

/// Defines type of a session - what kind of trading activity is allowed (if any),
/// what rules are used, what impact on daily trading statistics it has, etc..
/// 
/// The ``noTrading`` session type is used for non-trading sessions.
///
/// Some exchanges support all session types defined here, others do not.
///
/// Some sessions may have zero duration - e.g. indices that post value once a day.
/// Such sessions can be of any appropriate type, trading or non-trading.

public enum ScheduleSessionType {
    /// Non-trading session type is used to mark periods of time during which trading is not allowed. */
    case noTrading
    /// Pre-market session type marks extended trading session before regular trading hours. */
    case preMarket
    /// Regular session type marks regular trading hours session. */
    case regular
    /// After-market session type marks extended trading session after regular trading hours. */
    case afterMarket
}

/// Session represents a continuous period of time during which apply same rules regarding trading activity.
/// For example, regular trading session is a period of time consisting of one day of business activities
/// in a financial market, from the opening bell to the closing bell, when regular trading occurs.
///
/// Sessions can be either trading or non-trading, with different sets of rules and reasons to exist.
/// Sessions do not overlap with each other - rather they form consecutive chain of adjacent periods of time that
/// cover entire time scale. The point on a border line is considered to belong to following session that starts there.
/// Each session completely fits inside a certain day. Day may contain sessions with zero duration - e.g. indices
/// that post value once a day. Such sessions can be of any appropriate type, trading or non-trading.
public class ScheduleSession {
    internal let native: NativeSession
    internal let nativeSchedule: NativeSchedule
    /// Returns start time of this session (inclusive).
    /// For normal sessions the start time is less than the end time, for empty sessions they are equal.
    public let startTime: Long
    /// Returns end time of this session (exclusive).
    ///
    /// For normal sessions the end time is greater than the start time, for empty sessions they are equal.
    public let endTime: Long
    /// Returns type of this session.
    public let type: ScheduleSessionType

    init(native: NativeSession,
         nativeSchedule: NativeSchedule,
         startTime: Long,
         endTime: Long,
         type: ScheduleSessionType) {
        self.native = native
        self.nativeSchedule = nativeSchedule
        self.startTime = startTime
        self.endTime = endTime
        self.type = type
    }
}


extension ScheduleSession {
    public func getPrevious(filter: SessionFilter) throws -> ScheduleSession? {
        return try nativeSchedule.getPrevtSession(before: self, filter: filter)
    }

    public func getNext(filter: SessionFilter) throws -> ScheduleSession? {
        return try nativeSchedule.getNextSession(after: self, filter: filter)
    }
}

extension ScheduleSession: Equatable {
    public static func == (lhs: ScheduleSession, rhs: ScheduleSession) -> Bool {
        return lhs === rhs ||
        (lhs.endTime == rhs.endTime && lhs.startTime == rhs.startTime && lhs.type == rhs.type)
    }


}
