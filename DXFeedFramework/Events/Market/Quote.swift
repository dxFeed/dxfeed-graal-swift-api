//
//  Quote.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 05.06.23.
//

import Foundation

public class Quote: MarketEvent, ILastingEvent, CustomStringConvertible {
    public let type: EventCode = .quote
    public var eventSymbol: String
    public var eventTime: Int64 = 0

    internal var timeMillisSequence: Int32 = 0
    public var timeNanoPart: Int32 = 0
    public var bidTime: Int64 = 0 {
        didSet {
            recomputeTimeMillisPart()
        }
    }
    public var bidExchangeCode: Int16 = 0
    public var bidPrice: Double = .nan
    public var bidSize: Double = .nan
    public var askTime: Int64 = 0 {
        didSet {
            recomputeTimeMillisPart()
        }
    }
    public var askExchangeCode: Int16 = 0
    public var askPrice: Double = .nan
    public var askSize: Double = .nan
    init(_ symbol: String) {
        self.eventSymbol = symbol
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

    public func getSequence() -> Int {
        return Int(timeMillisSequence & MarketEventConst.maxSequence)
    }

    public func setSequence(_ sequence: Int) throws {
        if sequence < 0 || sequence > MarketEventConst.maxSequence {
            throw ArgumentException.exception(
                "Sequence(\(sequence) is < 0 or > MaxSequence(\(MarketEventConst.maxSequence)"
            )
        }
        timeMillisSequence = Int32(timeMillisSequence & ~MarketEventConst.maxSequence) | Int32(sequence)
    }

    public var time: Int64 {
        (MathUtil.floorDiv(max(bidTime, askTime), 1000) * 1000) + (Int64(timeMillisSequence) >> 22)
    }

    public var timeNanos: Int64 {
        return TimeNanosUtil.getNanosFromMillisAndNanoPart(time, timeNanoPart)
    }

    func toString() -> String {
        return "Quote{\(baseFieldsToString())}"
    }

    func baseFieldsToString() -> String {
        return """
\(eventSymbol), \
eventTime=" + \(TimeUtil.toLocalDateString(millis: eventTime)), \
time=\(TimeUtil.toLocalDateString(millis: time)), \
timeNanoPart=\(timeNanoPart), \
sequence=\(getSequence()), \
bidTime=\(TimeUtil.toLocalDateStringWithoutMillis(millis: bidTime)), \
bidExchange=\(StringUtil.encodeChar(char: bidExchangeCode)), \
bidPrice=\(bidPrice), \
bidSize=\(bidSize), \
askTime=\(TimeUtil.toLocalDateStringWithoutMillis(millis: askTime)), \
askExchange=\(StringUtil.encodeChar(char: askExchangeCode)), \
askPrice=\(askPrice), \
askSize=\(askSize)
"""
    }
}
