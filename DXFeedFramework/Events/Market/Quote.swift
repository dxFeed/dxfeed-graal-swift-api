//
//  Quote.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 05.06.23.
//

import Foundation

/// Quote event is a snapshot of the best bid and ask prices, and other fields that change with each quote.
///
/// It represents the most recent information that is available about the best quote on the market
/// at any given moment of time.
/// 
/// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/market/Quote.html)
public class Quote: MarketEvent, ILastingEvent, CustomStringConvertible {
    public let type: EventCode = .quote
    public var eventSymbol: String
    public var eventTime: Int64 = 0
    /// Gets or sets time millis sequence.
    /// Do not sets this value directly.
    /// Change ``setSequence(_:)`` and/or ``time``.
    internal var timeMillisSequence: Int32 = 0
    /// Gets or sets microseconds and nanoseconds part of time of the last bid or ask change.
    /// This method changes ``timeNanos`` result.
    public var timeNanoPart: Int32 = 0
    /// Gets or sets time of the last bid change.
    /// Time is measured in milliseconds between the current time and midnight, January 1, 1970 UTC.
    /// This time is always transmitted with seconds precision, so the result of this method is
    /// usually a multiple of 1000.
    /// 
    /// You can set the actual millisecond-precision time here to publish event and
    /// the millisecond part will make the time of this quote even precise up to a millisecond.
    public var bidTime: Int64 = 0 {
        didSet {
            recomputeTimeMillisPart()
        }
    }
    /// Gets or sets bid exchange code.
    public var bidExchangeCode: Int16 = 0
    /// Gets or sets bid price.
    public var bidPrice: Double = .nan
    /// Gets or sets bid size.
    public var bidSize: Double = .nan
    /// Gets or sets time of the last ask change.
    ///
    /// Time is measured in milliseconds between the current time and midnight, January 1, 1970 UTC.
    /// This time is always transmitted with seconds precision, so the result of this method is
    /// usually a multiple of 1000.
    /// 
    /// You can set the actual millisecond-precision time here to publish event and
    /// the millisecond part will make the time of this quote even precise up to a millisecond.
    public var askTime: Int64 = 0 {
        didSet {
            recomputeTimeMillisPart()
        }
    }
    /// Gets or sets ask exchange code.
    public var askExchangeCode: Int16 = 0
    /// Gets or sets ask price.
    public var askPrice: Double = .nan
    /// Gets or sets ask size.
    public var askSize: Double = .nan

    /// Initializes a new instance of the ``Quote`` class.
    public init(_ symbol: String) {
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
    private func recomputeTimeMillisPart() {
        timeMillisSequence = Int32(TimeUtil.getMillisFromTime(max(askTime, bidTime) << 22) | 0)
    }

    /// Gets sequence number of this quote to distinguish quotes that have the same ``time``.
    /// This sequence number does not have to be unique and
    /// does not need to be sequential. Sequence can range from 0 to ``MarketEventConst/maxSequence``.
    public func getSequence() -> Int {
        return Int(timeMillisSequence & MarketEventConst.maxSequence)
    }
    /// Sets sequence number of this quote to distinguish quotes that have the same ``time``.
    /// This sequence number does not have to be unique and
    /// does not need to be sequential. Sequence can range from 0 to ``MarketEventConst/maxSequence``.
    /// - Throws: ``ArgumentException/exception(_:)``
    public func setSequence(_ sequence: Int) throws {
        if sequence < 0 || sequence > MarketEventConst.maxSequence {
            throw ArgumentException.exception(
                "Sequence(\(sequence) is < 0 or > MaxSequence(\(MarketEventConst.maxSequence)"
            )
        }
        timeMillisSequence = Int32(timeMillisSequence & ~MarketEventConst.maxSequence) | Int32(sequence)
    }
    /// Gets time of the last bid or ask change.
    ///
    /// Time is measured in milliseconds between the current time and midnight, January 1, 1970 UTC.
    public var time: Int64 {
        (MathUtil.floorDiv(max(bidTime, askTime), 1000) * 1000) + (Int64(timeMillisSequence) >> 22)
    }

    /// Gets time of the last bid or ask change in nanoseconds.
    ///
    /// Time is measured in nanoseconds between the current time and midnight, January 1, 1970 UTC.
    public var timeNanos: Int64 {
        return TimeNanosUtil.getNanosFromMillisAndNanoPart(time, timeNanoPart)
    }
    /// Returns string representation of this quote event.
    public func toString() -> String {
        return "Quote{\(baseFieldsToString())}"
    }

    func baseFieldsToString() -> String {
        return """
\(eventSymbol), \
eventTime=\(TimeUtil.toLocalDateString(millis: eventTime)), \
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
