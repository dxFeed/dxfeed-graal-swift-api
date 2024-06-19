//
//  DayFilter.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 18.09.23.
//

import Foundation

public enum DayFilter: Int, CaseIterable {
    case any = 0
    case trading
    case nonTrading
    case holiday
    case shortDay
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    case weekDay
    case weekEnd
}
