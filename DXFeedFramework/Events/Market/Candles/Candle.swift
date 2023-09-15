//
//  Candle.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 13.07.23.
//

import Foundation
/// Candle event with open, high, low, close prices and other information for a specific period.
///
/// Candles are build with a specified ``CandlePeriod`` using a specified ``CandlePrice`` type
/// with a data taken from the specified ``CandleExchange`` from the specified ``CandleSession``
/// with further details of aggregation provided by ``CandleAlignment``.
public class Candle: MarketEvent, ITimeSeriesEvent, ILastingEvent, CustomStringConvertible {
    public let type: EventCode = .candle

    /// Gets or sets candle symbol object.
    public var eventSymbol: String {
        get {
            candleSymbol?.toString() ?? ""
        }
        set {
            candleSymbol = try? CandleSymbol.valueOf(newValue)
        }
    }
    public var eventTime: Int64 = 0

    /*
     * EventFlags property has several significant bits that are packed into an integer in the following way:
     *    31..7    6    5    4    3    2    1    0
     * +---------+----+----+----+----+----+----+----+
     * |         | SM |    | SS | SE | SB | RE | TX |
     * +---------+----+----+----+----+----+----+----+
     */

    /// Gets or sets candle symbol object.
    public var candleSymbol: CandleSymbol?
    /// Gets or sets total number of original trade (or quote) events in this candle.
    public var count: Long = 0
    /// Gets or sets the first (open) price of this candle.
    public var open: Double = .nan
    /// Gets or sets the maximal (high) price of this candle.
    public var high: Double = .nan
    /// Gets or sets the minimal (low) price of this candle.
    public var low: Double = .nan
    /// Gets or sets the last (close) price of this candle.
    public var close: Double = .nan
    /// Gets or sets total volume in this candle as floating number with fractions.
    /// Total turnover in this candle can be computed with ``vwap`` * ``volume``.
    public var volume: Double = .nan
    /// Gets or sets volume-weighted average price (VWAP) in this candle.
    /// Total turnover in this candle can be computed with ``vwap`` * ``volume``.
    public var vwap: Double = .nan
    /// Gets or sets bid volume in this candle as floating number with fractions.
    public var bidVolume: Double = .nan
    /// Gets or sets ask volume in this candle as floating number with fractions.
    public var askVolume: Double = .nan
    /// Gets or sets implied volatility.
    public var impVolatility: Double = .nan
    /// Gets or sets open interest as floating number with fractions.
    public var openInterest: Double = .nan

    public var eventSource = IndexedEventSource.defaultSource
    public var eventFlags: Int32 = 0
    public var index: Long = 0

    /// Initializes a new instance of the ``Candle`` class with the specified event symbol.
    public convenience init(_ symbol: CandleSymbol) {
        self.init()
        self.candleSymbol = symbol
    }

    public var description: String {
        """
DXFG_CANDLE_T \
eventSymbol: \(eventSymbol) \
eventTime: \(Date(timeIntervalSince1970: TimeInterval(Double(time/1000)))) \
eventSymbol: \(eventSymbol), \
eventTime: \(eventTime), \
eventFlags: \(eventFlags), \
index: \(index), \
count: \(count), \
open: \(open), \
high: \(high), \
low: \(low), \
close: \(close), \
volume: \(volume), \
vwap: \(vwap), \
bidVolume: \(bidVolume), \
askVolume: \(askVolume), \
impVolatility: \(impVolatility), \
openInterest: \(openInterest)
"""
    }
}

extension Candle {
    /// Gets  sequence number of this event to distinguish events that have the same ``time``
    /// This sequence number does not have to be unique and
    /// does not need to be sequential. Sequence can range from 0 to ``MarketEventConst/maxSequence``>.
    public func getSequence() -> Int {
        return Int(index) & Int(MarketEventConst.maxSequence)
    }

    /// Sets  sequence number of this event to distinguish events that have the same ``time``
    /// This sequence number does not have to be unique and
    /// does not need to be sequential. Sequence can range from 0 to ``MarketEventConst/maxSequence``>.
    ///
    /// - Throws: ``ArgumentException/exception(_:)``
    public func setSequence(_ sequence: Int) throws {
        if sequence < 0 || sequence > MarketEventConst.maxSequence {
            throw ArgumentException.exception(
                "Sequence(\(sequence) is < 0 or > MaxSequence(\(MarketEventConst.maxSequence)"
            )
        }
        index = (index & ~Int64(MarketEventConst.maxSequence)) | Int64(sequence)
    }
    /// Gets or sets timestamp of the original event.
    /// Time is measured in milliseconds between the current time and midnight, January 1, 1970 UTC.
    public var time: Int64 {
        get {
            Int64(((self.index >> 32) * 1000) + ((self.index >> 22) & 0x3ff))
        }
        set {
            index = (Long(TimeUtil.getSecondsFromTime(newValue)) << 32) |
            Long(TimeUtil.getMillisFromTime(newValue) << 22) | Long(getSequence())
        }
    }

    /// Returns string representation of this candle event.
    func toString() -> String {
        return "Candle{\(baseFieldsToString())}"
    }

    /// Returns string representation of this candle fields.
    func baseFieldsToString() -> String {
        return """
\(eventSymbol), \
eventTime=" + \(TimeUtil.toLocalDateString(millis: eventTime)), \
eventFlags=0x\(String(format: "%02X", eventFlags)), \
time=\(TimeUtil.toLocalDateString(millis: time)), \
sequence=\(getSequence()), \
count=\(count), \
open=\(open), \
high=\(high), \
low=\(low), \
close=\(close), \
volume=\(volume), \
vwap=\(vwap), \
bidVolume=\(bidVolume), \
askVolume=\(askVolume), \
impVolatility=\(impVolatility), \
openInterest=\(openInterest)
"""
    }
}
