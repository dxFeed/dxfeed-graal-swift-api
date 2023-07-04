//
//  EventCode+Native.swift
//  DXFeedFramework
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
    func nativeCode() -> dxfg_event_clazz_t {
        switch self {
        case .quote:
            return DXFG_EVENT_QUOTE
        case .profile:
            return DXFG_EVENT_PROFILE
        case .summary:
            return DXFG_EVENT_SUMMARY
        case .greeks:
            return DXFG_EVENT_GREEKS
        case .candle:
            return DXFG_EVENT_CANDLE
        case .dailyCandle:
            return DXFG_EVENT_DAILY_CANDLE
        case .underlying:
            return DXFG_EVENT_UNDERLYING
        case .theoPrice:
            return DXFG_EVENT_THEO_PRICE
        case .trade:
            return DXFG_EVENT_TRADE
        case .tradeETH:
            return DXFG_EVENT_TRADE_ETH
        case .configuration:
            return DXFG_EVENT_CONFIGURATION
        case .message:
            return DXFG_EVENT_MESSAGE
        case .timeAndSale:
            return DXFG_EVENT_TIME_AND_SALE
        case .orderBase:
            return DXFG_EVENT_ORDER_BASE
        case .order:
            return DXFG_EVENT_ORDER
        case .analyticOrder:
            return DXFG_EVENT_ANALYTIC_ORDER
        case .spreadOrder:
            return DXFG_EVENT_SPREAD_ORDER
        case .series:
            return DXFG_EVENT_SERIES
        case .optionSale:
            return DXFG_EVENT_OPTION_SALE
        }
    }

    static func differentCodesAfterConversation() -> [EventCode] {
        let convertedSet = Set(EventCode.allCases.map { $0.nativeCode() }.compactMap { EventCode.convert($0)  })
        return Array(Set(EventCode.allCases).symmetricDifference(convertedSet))
    }
}
