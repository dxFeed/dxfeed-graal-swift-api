//
//  Profile.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 07.06.23.
//

import Foundation

public class Profile: MarketEvent, ILastingEvent, CustomStringConvertible {
    public let type: EventCode = .profile
    public var eventSymbol: String
    public var eventTime: Int64 = 0

    public var descriptionStr: String?
    public var statusReason: String?
    public var haltStartTime: Long = 0
    public var haltEndTime: Long = 0
    public var highLimitPrice: Double = .nan
    public var lowLimitPrice: Double = .nan
    public var high52WeekPrice: Double = .nan
    public var low52WeekPrice: Double = .nan
    public var beta: Double = .nan
    public var earningsPerShare: Double = .nan
    public var dividendFrequency: Double = .nan
    public var exDividendAmount: Double = .nan
    public var exDividendDayId: Int32 = 0
    public var shares: Double = .nan
    public var freeFloat: Double = .nan
    public var flags: Int32 = 0

    // SSR values are taken from ShortSaleRestriction enum.
    private let ssrMask = 3
    private let ssrShift = 2

    // STATUS values are taken from TradingStatus enum.
    private let statusMask = 3
    private let statusShift = 0

    init(_ symbol: String) {
        self.eventSymbol = symbol
    }

    public var description: String {
"""
DXFG_PROFILE_T \
eventSymbol: \(eventSymbol) \
eventTime: \(eventTime) \
description: \(descriptionStr ?? "null"), \
statusReason: \(statusReason ?? "null"), \
haltStartTime: \(haltStartTime), \
haltEndTime: \(haltEndTime), \
highLimitPrice: \(highLimitPrice), \
lowLimitPrice: \(lowLimitPrice), \
high52WeekPrice: \(high52WeekPrice), \
low52WeekPrice: \(low52WeekPrice), \
beta: \(beta), \
earningsPerShare: \(earningsPerShare), \
dividendFrequency: \(dividendFrequency), \
exDividendAmount: \(exDividendAmount), \
exDividendDayId: \(exDividendDayId), \
shares: \(shares), \
freeFloat: \(freeFloat), \
flags: \(flags)
"""
    }
}

extension Profile {
    public var shortSaleRestriction: ShortSaleRestriction {
        get {
            ShortSaleRestriction.valueOf(Int(BitUtil.getBits(flags: Int(flags), mask: ssrMask, shift: ssrShift)))
        }
        set {
            flags = Int32(BitUtil.setBits(flags: Int(flags), mask: ssrMask, shift: ssrShift, bits: newValue.rawValue))
        }
    }

    public var isShortSaleRestricted: Bool {
        shortSaleRestriction == .active
    }

    public var tradingStatus: TradingStatus {
        get {
            TradingStatus.valueOf(BitUtil.getBits(flags: Int(flags), mask: statusMask, shift: statusShift))
        }
        set {
            flags = Int32(BitUtil.setBits(flags: Int(flags),
                                          mask: statusMask,
                                          shift: statusShift,
                                          bits: newValue.rawValue))
        }
    }

    public var isTradingHalted: Bool {
        return tradingStatus == .halted
    }

    func toString() -> String {
        return "Profile{\(baseFieldsToString())}"
    }

    func baseFieldsToString() -> String {
        return """
\(eventSymbol), \
eventTime=\(TimeUtil.toLocalDateString(millis: eventTime)), \
description='\(descriptionStr ?? "null")', \
SSR=\(shortSaleRestriction), \
status=\(tradingStatus), \
statusReason='\(statusReason ?? "null")', \
haltStartTime=\(TimeUtil.toLocalDateString(millis: haltStartTime)), \
haltEndTime=\(TimeUtil.toLocalDateString(millis: haltEndTime)), \
highLimitPrice=\(highLimitPrice), \
lowLimitPrice=\(lowLimitPrice), \
high52WeekPrice=\(high52WeekPrice), \
low52WeekPrice=\(low52WeekPrice), \
beta=\(beta), \
earningsPerShare=\(earningsPerShare), \
dividendFrequency=\(dividendFrequency), \
exDividendAmount=\(exDividendAmount), \
exDividendDay=\(DayUtil.getYearMonthDayByDayId(Int(exDividendDayId))), \
shares=\(shares), \
freeFloat=\(freeFloat)
"""
    }
}
