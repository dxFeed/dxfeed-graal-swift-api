//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
/// Base class for common fields of ``Trade`` and ``TradeETH`` events.
///
/// Trade events represent the most receаnt information that is available about the last trade on the market
/// at any given moment of time.
///
/// [For more details see] (https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/market/TradeBase.html)
public class TradeBase: MarketEvent, ILastingEvent {
    /*
     * Flags property has several significant bits that are packed into an integer in the following way:
     *   31..4     3    2    1    0
     * +--------+----+----+----+----+
     * |        |  Direction   | ETH|
     * +--------+----+----+----+----+
     */

    /// Gets or sets time and sequence of last trade packaged into single long value.
    ///
    /// **Do not set this property directly.**
    /// 
    /// Sets ``time`` and/or ``setSequence(_:)``.
    public internal(set) var timeSequence: Long = 0
    /// Gets or sets microseconds and nanoseconds time part of the last trade.
    public var timeNanoPart: Int32 = 0
    /// Gets or sets exchange code of the last trade.
    public var exchangeCode: Int16 = 0
    /// Gets or sets price of the last trade.
    public var price: Double = .nan
    /// Gets or sets change of the last trade.
    public var change: Double = .nan
    /// Gets or sets size of this last trade event as floating number with fractions.
    public var size: Double = .nan
    /// Gets or sets identifier of the current trading day.
    /// Identifier of the day is the number of days passed since January 1, 1970.
    public var dayId: Int32 = 0
    /// Gets or sets total volume traded for a day as floating number with fractions.
    public var dayVolume: Double = .nan
    /// Gets or sets total turnover traded for a day.
    /// Day VWAP can be computed with  ``dayTurnover`` / ``dayVolume``.
    public var dayTurnover: Double = .nan
    /// Gets or sets implementation-specific flags.
    /// Do not use this method directly.
    var flags: Int32 = 0

    public init(symbol: String, type: EventCode) {
        super.init()
        self.eventSymbol = symbol
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

    /// Returns string representation of this base trade event's.
    public override func toString() -> String {
        return "\(typeName){\(baseFieldsToString())}"
    }

    var typeName: String {
        let thisType = Swift.type(of: self)
        return String(describing: thisType)
    }
}

extension TradeBase {
    // DIRECTION values are taken from Direction enum.
    private static let directionMask = Int32(7)
    private static let directionShift = Int32(1)
    // ETH mask.
    private static let eth = Int32(1)

    /// Gets or sets tick direction of the last trade.
    public var tickDirection: Direction {
        get {
            Direction.valueOf(Int(BitUtil.getBits(flags: flags,
                                                  mask: TradeBase.directionMask,
                                                  shift: TradeBase.directionShift)))
        }
        set {
            flags = BitUtil.setBits(flags: flags,
                                    mask: TradeBase.directionMask,
                                    shift: TradeBase.directionShift,
                                    bits: newValue.rawValue)
        }
    }

    /// Gets or sets a value indicating whether last trade was in extended trading hours.
    public var isExtendedTradingHours: Bool {
        get {
            flags & TradeBase.eth != 0
        }
        set {
            flags = newValue ? flags | TradeBase.eth : flags & ~TradeBase.eth
        }
    }
    /// Gets sequence number of the last trade to distinguish trades that have the same ``time``.
    ///
    /// This sequence number does not have to be unique and
    /// does not need to be sequential. Sequence can range from 0 to ``MarketEventConst/maxSequence``.
    public func getSequence() -> Int {
        return Int(timeSequence) & Int(MarketEventConst.maxSequence)
    }

    /// Sets sequence number of the last trade to distinguish trades that have the same ``time``.
    ///
    /// This sequence number does not have to be unique and
    /// does not need to be sequential. Sequence can range from 0 to ``MarketEventConst/maxSequence``.
    ///
    /// - Throws: ``ArgumentException/exception(_:)``
    public func setSequence(_ sequence: Int) throws {
        if sequence < 0 && sequence > MarketEventConst.maxSequence {
            throw ArgumentException.exception(
                "Sequence(\(sequence) is < 0 or > MaxSequence(\(MarketEventConst.maxSequence)"
            )
        }
        timeSequence = (timeSequence & Long(~MarketEventConst.maxSequence)) | Int64(sequence)
    }

    /// Gets or sets time of the last trade.
   /// Time is measured in milliseconds between the current time and midnight, January 1, 1970 UTC.
    public var time: Long {
        get {
            ((timeSequence >> 32) * 1000) + ((timeSequence >> 22) & 0x3ff)
        }
        set {
            timeSequence = Long(TimeUtil.getSecondsFromTime(newValue) << 32) |
            (Long(TimeUtil.getMillisFromTime(newValue)) << 22) |
            newValue
        }
    }

    /// Gets or sets time of the last trade in nanoseconds.
    /// Time is measured in nanoseconds between the current time and midnight, January 1, 1970 UTC.
    public var timeNanos: Long {
        get {
            TimeNanosUtil.getNanosFromMillisAndNanoPart(time, timeNanoPart)
        }
        set {
            time = TimeNanosUtil.getMillisFromNanos(newValue)
            timeNanoPart = Int32(TimeNanosUtil.getNanoPartFromNanos(newValue))
        }
    }

    /// Returns string representation of this trade fields.
    func baseFieldsToString() -> String {
        return """
\(eventSymbol), \
eventTime=\((try? DXTimeFormat.defaultTimeFormat?.withMillis?.format(value: eventTime)) ?? ""), \
time=\((try? DXTimeFormat.defaultTimeFormat?.withMillis?.format(value: time)) ?? ""), \
timeNanoPart=\(timeNanoPart), \
sequence=\(self.getSequence()), \
exchange=\(StringUtil.encodeChar(char: exchangeCode)), \
price=\(price), \
change=\(change), \
size=\(size), \
day=\(DayUtil.getYearMonthDayByDayId(Int(dayId))), \
dayVolume=\(dayVolume), \
dayTurnover=\(dayTurnover), \
direction=\(tickDirection), \
ETH=\(isExtendedTradingHours)
"""
    }
}
