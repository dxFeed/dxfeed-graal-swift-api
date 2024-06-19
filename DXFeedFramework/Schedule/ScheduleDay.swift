//
//  ScheduleDay.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 13.09.23.
//

import Foundation

public class ScheduleDay {
    public internal(set) var dayId: Int32 = 0
    public internal(set) var yearMonthDay: Int32 = 0
    public internal(set) var year: Int32 = 0
    public internal(set) var monthOfYear: Int32 = 0
    public internal(set) var dayOfMonth: Int32 = 0
    public internal(set) var dayOfWeek: Int32 = 0
    public internal(set) var holiday: Int32 = 0
    public internal(set) var shortDay: Int32 = 0
    public internal(set) var resetTime: Int64 = 0
    public internal(set) var trading: Int32 = 0
    public internal(set) var startTime: Int64 = 0
    public internal(set) var endTime: Int64 = 0
    public internal(set) var sessions = [ScheduleSession]()
}
