//
//  Quote.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 05.06.23.
//

import Foundation

public class Quote: MarketEvent, ILastingEvent, CustomStringConvertible {

    public let maxSequence = Int32((1 << 22) - 1)

    public let type: EventCode = .quote
    public var eventSymbol: String
    public var eventTime: Int64

    internal var timeMillisSequence: Int32
    public var timeNanoPart: Int32
    public var bidTime: Int64 {
        didSet {
            recomputeTimeMillisPart()
        }
    }
    public var bidExchangeCode: Int16
    public var bidPrice = Double.nan
    public var bidSize =  Double.nan
    public var askTime: Int64 {
        didSet {
            recomputeTimeMillisPart()
        }
    }
    public var askExchangeCode: Int16
    public var askPrice: Double
    public var askSize: Double

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

extension Quote {
    func recomputeTimeMillisPart() {
        timeMillisSequence = Int32(TimeUtil.getMillisFromTime(max<Int64>(askTime, bidTime) << 22) | 0)
    }

    public func getSequence() -> Int32 {
        return timeMillisSequence & maxSequence
    }

    public func setSequence(_ sequence: Int32) throws {
        if sequence < 0 || sequence > maxSequence {
            throw ArgumentException.illegalArgumentException
        }
        timeMillisSequence = (timeMillisSequence & ~maxSequence) | sequence
    }

    public var time: Int64 {
        (MathUtil.floorDiv(max(bidTime, askTime), 1000) * 1000) + (Int64(timeMillisSequence) >> 22)
    }

    public var timeNanos: Int64 {
        return TimeNanosUtil.getNanosFromMillisAndNanoPart(time, timeNanoPart)
    }
}
