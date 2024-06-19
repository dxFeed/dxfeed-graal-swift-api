//
//  ScheduleSessionType+Ext.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 13.09.23.
//

import Foundation
@_implementationOnly import graal_api

extension ScheduleSessionType {
    static func getValueFromNative(_ type: dxfg_session_type_t) -> ScheduleSessionType {
        switch type {
        case DXFG_SESSION_TYPE_NO_TRADING:
            return .noTrading
        case DXFG_SESSION_TYPE_PRE_MARKET:
            return .preMarket
        case DXFG_SESSION_TYPE_REGULAR:
            return .regular
        case DXFG_SESSION_TYPE_AFTER_MARKET:
            return .afterMarket
        default:
            fatalError()
        }
    }
}
