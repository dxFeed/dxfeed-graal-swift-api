//
//  Candle.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 13.07.23.
//

import Foundation

public class Candle: MarketEvent, CustomStringConvertible {
    public let type: EventCode = .candle
    public let eventSymbol: String
    public let eventTime: Int64

    public let eventFlags: Int32
    public let index: Int64
    public let count: Int64
    public let open: Double
    public let high: Double
    public let low: Double
    public let close: Double
    public let volume: Double
    public let vwap: Double
    public let bidVolume: Double
    public let askVolume: Double
    public let impVolatility: Double
    public let openInterest: Double
    init(eventSymbol: String,
         eventTime: Int64,
         eventFlags: Int32,
         index: Int64,
         count: Int64,
         open: Double,
         high: Double,
         low: Double,
         close: Double,
         volume: Double,
         vwap: Double,
         bidVolume: Double,
         askVolume: Double,
         impVolatility: Double,
         openInterest: Double) {

        self.eventSymbol = eventSymbol
        self.eventTime = eventTime
        self.eventFlags = eventFlags
        self.index = index
        self.count = count
        self.open = open
        self.high = high
        self.low = low
        self.close = close
        self.volume = volume
        self.vwap = vwap
        self.bidVolume = bidVolume
        self.askVolume = askVolume
        self.impVolatility = impVolatility
        self.openInterest = openInterest
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
