//
//  DayFilter+Ext.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 18.09.23.
//

import Foundation
@_implementationOnly import graal_api

extension DayFilter {
    init(value: dxfg_day_filter_prepare_t) {
        switch value {
        case DXFG_DAY_FILTER_ANY:
            self = .any
        case DXFG_DAY_FILTER_TRADING:
            self = .trading
        case DXFG_DAY_FILTER_NON_TRADING:
            self = .nonTrading
        case DXFG_DAY_FILTER_HOLIDAY:
            self = .holiday
        case DXFG_DAY_FILTER_SHORT_DAY:
            self = .shortDay
        case DXFG_DAY_FILTER_MONDAY:
            self = .monday
        case DXFG_DAY_FILTER_TUESDAY:
            self = .tuesday
        case DXFG_DAY_FILTER_WEDNESDAY:
            self = .wednesday
        case DXFG_DAY_FILTER_THURSDAY:
            self = .thursday
        case DXFG_DAY_FILTER_FRIDAY:
            self = .friday
        case DXFG_DAY_FILTER_SATURDAY:
            self = .saturday
        case DXFG_DAY_FILTER_SUNDAY:
            self = .sunday
        case DXFG_DAY_FILTER_WEEK_DAY:
            self = .weekDay
        case DXFG_DAY_FILTER_WEEK_END:
            self = .weekEnd
        default:
            fatalError("Wrong qd-value \(value) for DayFilter")
        }
    }

    func toQDValue() -> dxfg_day_filter_prepare_t {
        switch self {
        case .any:
            return DXFG_DAY_FILTER_ANY
        case .trading:
            return DXFG_DAY_FILTER_TRADING
        case .nonTrading:
            return DXFG_DAY_FILTER_NON_TRADING
        case .holiday:
            return DXFG_DAY_FILTER_HOLIDAY
        case .shortDay:
            return DXFG_DAY_FILTER_SHORT_DAY
        case .monday:
            return DXFG_DAY_FILTER_MONDAY
        case .tuesday:
            return DXFG_DAY_FILTER_TUESDAY
        case .wednesday:
            return DXFG_DAY_FILTER_WEDNESDAY
        case .thursday:
            return DXFG_DAY_FILTER_THURSDAY
        case .friday:
            return DXFG_DAY_FILTER_FRIDAY
        case .saturday:
            return DXFG_DAY_FILTER_SATURDAY
        case .sunday:
            return DXFG_DAY_FILTER_SUNDAY
        case .weekDay:
            return DXFG_DAY_FILTER_WEEK_DAY
        case .weekEnd:
            return DXFG_DAY_FILTER_WEEK_END
        }
    }
}
