//
//  TradeBase.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 07.06.23.
//

import Foundation

public class TradeBase: MarketEvent, ILastingEvent {
    public let type: EventCode

    public var eventSymbol: String
    public var eventTime: Int64

    public let timeSequence: Int64
    public let timeNanoPart: Int32
    public let exchangeCode: Int16
    public let price: Double
    public let change: Double
    public let size: Double
    public let dayId: Int32
    public let dayVolume: Double
    public let dayTurnover: Double
    public let flags: Int32
    init(type: EventCode,
         eventSymbol: String,
         eventTime: Int64,
         timeSequence: Int64,
         timeNanoPart: Int32,
         exchangeCode: Int16,
         price: Double,
         change: Double,
         size: Double,
         dayId: Int32,
         dayVolume: Double,
         dayTurnover: Double,
         flags: Int32) {
        self.type = type
        self.eventSymbol = eventSymbol
        self.eventTime = eventTime
        self.timeSequence = timeSequence
        self.timeNanoPart = timeNanoPart
        self.exchangeCode = exchangeCode
        self.price = price
        self.change = change
        self.size = size
        self.dayId = dayId
        self.dayVolume = dayVolume
        self.dayTurnover = dayTurnover
        self.flags = flags
    }
    public var description: String {
        """
DXFG_TRADE_BASE_T \
eventSymbol: \(eventSymbol) \
eventTime: \(eventTime) \
timeSequence: \(timeSequence), \
timeNanoPart: \(timeNanoPart), \
exchangeCode: \(exchangeCode), \
price: \(price), \
change: \(change), \
size: \(size), \
dayId: \(dayId), \
dayVolume: \(dayVolume), \
dayTurnover: \(dayTurnover), \
flags: \(flags)
"""
    }
}
