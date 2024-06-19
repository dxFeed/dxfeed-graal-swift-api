//
//  EventCode+Native.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 26.05.23.
//

import Foundation
@_implementationOnly import graal_api

extension EventCode {
    static func convert(_ code: dxfg_event_clazz_t) -> EventCode? {
        switch code {
        case DXFG_EVENT_QUOTE:
            return .quote
        case DXFG_EVENT_PROFILE:
            return .profile
        case DXFG_EVENT_SUMMARY:
            return .summary
        case DXFG_EVENT_GREEKS:
            return .greeks
        case DXFG_EVENT_CANDLE:
            return .candle
        case DXFG_EVENT_DAILY_CANDLE:
            return .dailyCandle
        case DXFG_EVENT_UNDERLYING:
            return .underlying
        case DXFG_EVENT_THEO_PRICE:
            return .theoPrice
        case DXFG_EVENT_TRADE:
            return .trade
        case DXFG_EVENT_TRADE_ETH:
            return .tradeETH
        case DXFG_EVENT_CONFIGURATION:
            return .configuration
        case DXFG_EVENT_MESSAGE:
            return .message
        case DXFG_EVENT_TIME_AND_SALE:
            return timeAndSale
        case DXFG_EVENT_ORDER_BASE:
            return orderBase
        case DXFG_EVENT_ORDER:
            return .order
        case DXFG_EVENT_ANALYTIC_ORDER:
            return .analyticOrder
        case DXFG_EVENT_SPREAD_ORDER:
            return .spreadOrder
        case DXFG_EVENT_SERIES:
            return .series
        case DXFG_EVENT_OPTION_SALE:
            return .optionSale
        default:
            return nil
        }
    }
}
