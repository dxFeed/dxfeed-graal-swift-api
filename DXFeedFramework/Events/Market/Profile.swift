//
//  Profile.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 07.06.23.
//

import Foundation
/// Profile information snapshot that contains security instrument description.
///
/// It represents the most recent information that is available about the traded security
/// on the market at any given moment of time.
/// 
/// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/market/Profile.html)
public class Profile: MarketEvent, ILastingEvent, CustomStringConvertible {
    public let type: EventCode = .profile
    public var eventSymbol: String
    public var eventTime: Int64 = 0

    /*
     * Flags property has several significant bits that are packed into an integer in the following way:
     *   31..4     3    2    1    0
     * +--------+----+----+----+----+
     * |        |   SSR   |  Status |
     * +--------+----+----+----+----+
     */

    /// Gets or sets description of the security instrument.
    public var descriptionStr: String?
    /// Gets or sets description of the reason that trading was halted.
    public var statusReason: String?
    /// Gets or sets starting time of the trading halt interval.
    /// Time is measured in milliseconds between the current time and midnight, January 1, 1970 UTC.
    public var haltStartTime: Long = 0
    // Gets or sets ending time of the trading halt interval.
    /// Time is measured in milliseconds between the current time and midnight, January 1, 1970 UTC.
    public var haltEndTime: Long = 0
    /// Gets or sets the maximal (high) allowed price.
    public var highLimitPrice: Double = .nan
    /// Gets or sets the minimal (low) allowed price.
    public var lowLimitPrice: Double = .nan
    /// Gets or sets the maximal (high) price in last 52 weeks.
    public var high52WeekPrice: Double = .nan
    /// Gets or sets the minimal (low) price in last 52 weeks.
    public var low52WeekPrice: Double = .nan
    /// Gets or sets the correlation coefficient of the instrument to the S&amp;P500 index.
    public var beta: Double = .nan
    /// Gets or sets the earnings per share (the company’s profits divided by the number of shares).
    public var earningsPerShare: Double = .nan
    /// Gets or sets the frequency of cash dividends payments per year (calculated).
    public var dividendFrequency: Double = .nan
    /// Gets or sets the amount of the last paid dividend.
    public var exDividendAmount: Double = .nan
    /// Gets or sets the identifier of the day of the last dividend payment (ex-dividend date).
    /// Identifier of the day is the number of days passed since January 1, 1970.
    public var exDividendDayId: Int32 = 0
    /// Gets or sets the the number of shares outstanding.
    public var shares: Double = .nan
    /// Gets or sets the free-float - the number of shares outstanding that are available to the public for trade.
    public var freeFloat: Double = .nan
    /// Gets or sets implementation-specific flags.
    /// **Do not use this method directly**
    var flags: Int32 = 0

    // SSR values are taken from ShortSaleRestriction enum.
    private let ssrMask = 3
    private let ssrShift = 2

    // STATUS values are taken from TradingStatus enum.
    private let statusMask = 3
    private let statusShift = 0

    /// Initializes a new instance of the ``Profile`` class.
    public init(_ symbol: String) {
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
    /// Gets or sets short sale restriction of the security instrument.
    public var shortSaleRestriction: ShortSaleRestriction {
        get {
            ShortSaleRestriction.valueOf(Int(BitUtil.getBits(flags: Int(flags), mask: ssrMask, shift: ssrShift)))
        }
        set {
            flags = Int32(BitUtil.setBits(flags: Int(flags), mask: ssrMask, shift: ssrShift, bits: newValue.rawValue))
        }
    }

    /// Gets a value indicating whether short sale of the security instrument is restricted.
    public var isShortSaleRestricted: Bool {
        shortSaleRestriction == .active
    }

    /// Gets or sets trading status of the security instrument.
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

    /// Gets a value indicating whether trading of the security instrument is halted.
    public var isTradingHalted: Bool {
        return tradingStatus == .halted
    }

    /// Returns string representation of this profile event.
    public func toString() -> String {
        return "Profile{\(baseFieldsToString())}"
    }

    /// Returns string representation of this order fields.
    func baseFieldsToString() -> String {
        return """
\(eventSymbol), \
eventTime=\((try? DXTimeFormat.defaultTimeFormat?.withMillis?.format(value: eventTime)) ?? ""), \
description='\(descriptionStr ?? "null")', \
SSR=\(shortSaleRestriction), \
status=\(tradingStatus), \
statusReason='\(statusReason ?? "null")', \
haltStartTime=\((try? DXTimeFormat.defaultTimeFormat?.format(value: haltStartTime)) ?? ""), \
haltEndTime=\((try? DXTimeFormat.defaultTimeFormat?.format(value: haltEndTime)) ?? ""), \
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
