//
//  Quote.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 05.06.23.
//

import Foundation

public class Quote: MarketEvent, CustomStringConvertible {
    public let type: EventCode = .quote
    public let eventSymbol: String
    public let eventTime: Int64

    public let timeMillisSequence: Int32
    public let timeNanoPart: Int32
    public let bidTime: Int64
    public let bidExchangeCode: Int16
    public let bidPrice: Double
    public let bidSize: Double
    public let askTime: Int64
    public let askExchangeCode: Int16
    public let askPrice: Double
    public let askSize: Double
    init(eventSymbol: String,
         eventTime: Int64,
         timeMillisSequence: Int32,
         timeNanoPart: Int32,
         bidTime: Int64,
         bidExchangeCode: Int16,
         bidPrice: Double,
         bidSize: Double,
         askTime: Int64,
         askExchangeCode: Int16,
         askPrice: Double,
         askSize: Double) {
        self.eventSymbol = eventSymbol
        self.eventTime = eventTime
        self.timeMillisSequence = timeMillisSequence
        self.timeNanoPart = timeNanoPart
        self.bidTime = bidTime
        self.bidExchangeCode = bidExchangeCode
        self.bidPrice = bidPrice
        self.bidSize = bidSize
        self.askTime = askTime
        self.askExchangeCode = askExchangeCode
        self.askPrice = askPrice
        self.askSize = askSize
    }
    public var description: String {
        """
DXFG_QUOTE_T \
eventSymbol: \(eventSymbol) \
eventTime: \(eventTime) \
timeMillisSequence: \(timeMillisSequence), \
timeNanoPart: \(timeNanoPart), \
bidTime: \(bidTime), \
bidExchangeCode: \(bidExchangeCode), \
bidPrice: \(bidPrice), \
bidSize: \(bidSize), \
askTime: \(askTime), \
askExchangeCode: \(askExchangeCode), \
askPrice: \(askPrice), \
askSize: \(askSize)
"""
    }
}
