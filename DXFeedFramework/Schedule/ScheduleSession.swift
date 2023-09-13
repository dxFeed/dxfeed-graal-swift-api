//
//  ScheduleSession.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 13.09.23.
//

import Foundation

public enum ScheduleSessionType {
    case noTrading
    case preMarket
    case regular
    case afterMarket
    case undefined
}

public class ScheduleSession {
    public let startTime: Long
    public let endTime: Long
    public let type: ScheduleSessionType

    init(startTime: Long, endTime: Long, type: ScheduleSessionType) {
        self.startTime = startTime
        self.endTime = endTime
        self.type = type
    }
}
