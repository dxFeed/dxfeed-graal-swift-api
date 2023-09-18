//
//  SessionFilter+Ext.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 18.09.23.
//

import Foundation
@_implementationOnly import graal_api

extension SessionFilter {
    init(value: dxfg_session_filter_prepare_t) {
        switch value {
        case DXFG_SESSION_FILTER_ANY:
            self = .any
        case DXFG_SESSION_FILTER_TRADING:
            self = .trading
        case DXFG_SESSION_FILTER_NON_TRADING:
            self = .nonTrading
        case DXFG_SESSION_FILTER_NO_TRADING:
            self = .noTrading
        case DXFG_SESSION_FILTER_PRE_MARKET:
            self = .preMarket
        case DXFG_SESSION_FILTER_REGULAR:
            self = .regular
        case DXFG_SESSION_FILTER_AFTER_MARKET:
            self = .afterMarket
        default:
            fatalError("Wrong qd-value \(value) for DayFilter")
        }
    }

    func toQDValue() -> dxfg_session_filter_prepare_t {
        switch self {
        case .any:
            return DXFG_SESSION_FILTER_ANY
        case .trading:
            return DXFG_SESSION_FILTER_TRADING
        case .nonTrading:
            return DXFG_SESSION_FILTER_NON_TRADING
        case .noTrading:
            return DXFG_SESSION_FILTER_NO_TRADING
        case .preMarket:
            return DXFG_SESSION_FILTER_PRE_MARKET
        case .regular:
            return DXFG_SESSION_FILTER_REGULAR
        case .afterMarket:
            return DXFG_SESSION_FILTER_AFTER_MARKET
        }
    }
}
