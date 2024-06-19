//
//  Candle.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 13.07.23.
//

import Foundation

public class Candle: MarketEvent, CustomStringConvertible {
    public let type: EventCode = .candle

    public var eventSymbol: String {
        get {
            candleSymbol?.toString() ?? ""
        }
        set {
            candleSymbol = try? CandleSymbol.valueOf(newValue)
        }
    }
    public var eventTime: Int64 = 0
    public var candleSymbol: CandleSymbol?

    public var eventFlags: Int32 = 0
    public var index: Long = 0
    public var count: Long = 0
    public var open: Double = .nan
    public var high: Double = .nan
    public var low: Double = .nan
    public var close: Double = .nan
    public var volume: Double = .nan
    public var vwap: Double = .nan
    public var bidVolume: Double = .nan
    public var askVolume: Double = .nan
    public var impVolatility: Double = .nan
    public var openInterest: Double = .nan

    convenience init(_ symbol: CandleSymbol) {
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

    public func getSequence() -> Int {
        return Int(index) & Int(MarketEventConst.maxSequence)
    }

    public func setSequence(_ sequence: Int) throws {
        if sequence < 0 || sequence > MarketEventConst.maxSequence {
            throw ArgumentException.exception(
                "Sequence(\(sequence) is < 0 or > MaxSequence(\(MarketEventConst.maxSequence)"
            )
        }
        index = (index & ~Int64(MarketEventConst.maxSequence)) | Int64(sequence)
    }

    func toString() -> String {
        return "Candle{\(baseFieldsToString())}"
    }

    func baseFieldsToString() -> String {
        return """
\(eventSymbol) ?? "null", \
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
