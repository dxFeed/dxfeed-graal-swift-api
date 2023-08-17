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
    public var eventTime: Int64

    public let descriptionStr: String
    public let statusReason: String
    public let haltStartTime: Int64
    public let haltEndTime: Int64
    public let highLimitPrice: Double
    public let lowLimitPrice: Double
    public let high52WeekPrice: Double
    public let low52WeekPrice: Double
    public let beta: Double
    public let earningsPerShare: Double
    public let dividendFrequency: Double
    public let exDividendAmount: Double
    public let exDividendDayId: Int32
    public let shares: Double
    public let freeFloat: Double
    public let flags: Int32
    init(eventSymbol: String,
         eventTime: Int64,
         description: String,
         statusReason: String,
         haltStartTime: Int64,
         haltEndTime: Int64,
         highLimitPrice: Double,
         lowLimitPrice: Double,
         high52WeekPrice: Double,
         low52WeekPrice: Double,
         beta: Double,
         earningsPerShare: Double,
         dividendFrequency: Double,
         exDividendAmount: Double,
         exDividendDayId: Int32,
         shares: Double,
         freeFloat: Double,
         flags: Int32) {
        self.eventSymbol = eventSymbol
        self.eventTime = eventTime
        self.descriptionStr = description
        self.statusReason = statusReason
        self.haltStartTime = haltStartTime
        self.haltEndTime = haltEndTime
        self.highLimitPrice = highLimitPrice
        self.lowLimitPrice = lowLimitPrice
        self.high52WeekPrice = high52WeekPrice
        self.low52WeekPrice = low52WeekPrice
        self.beta = beta
        self.earningsPerShare = earningsPerShare
        self.dividendFrequency = dividendFrequency
        self.exDividendAmount = exDividendAmount
        self.exDividendDayId = exDividendDayId
        self.shares = shares
        self.freeFloat = freeFloat
        self.flags = flags
    }
    public var description: String {
        """
DXFG_PROFILE_T \
eventSymbol: \(eventSymbol) \
eventTime: \(eventTime) \
description: \(descriptionStr), \
statusReason: \(statusReason), \
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
