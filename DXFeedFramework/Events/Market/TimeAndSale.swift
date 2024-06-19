//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
/// Time and Sale represents a trade or other market event with price, like market open/close price, etc.
///
/// Time and Sales are intended to provide information about trades in a continuous time slice
/// (unlike ``Trade`` events which are supposed to provide snapshot about the current last trade).
/// Time and Sale events have unique ``index``
/// which can be used for later correction/cancellation processing.
///
/// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/market/TimeAndSale.html)
public class TimeAndSale: MarketEvent, ITimeSeriesEvent, CustomStringConvertible {
    /*
     * Flags property has several significant bits that are packed into an integer in the following way:
     *   31..16   15...8    7    6    5    4    3    2    1    0
     * +--------+--------+----+----+----+----+----+----+----+----+
     * |        |   TTE  |    |  Side   | SL | ETH| VT |  Type   |
     * +--------+--------+----+----+----+----+----+----+----+----+
     */

    /// Gets or sets microseconds and nanoseconds time part of event.
    public var timeNanoPart: Int32 = 0
    /// Gets or sets exchange code of this time and sale event.
    public var exchangeCode: Int16 = 0
    /// Gets or sets price of this time and sale event.
    public var price: Double = .nan
    /// Gets or sets size of this time and sale event as floating number with fractions.
    public var size: Double = .nan
    /// Gets or sets the current bid price on the market when this time and sale event had occurred.
    public var bidPrice: Double = .nan
    /// Gets or sets the current ask price on the market when this time and sale event had occurred.
    public var askPrice: Double = .nan
    /// Gets or sets sale conditions provided for this event by data feed.
    /// This field format is specific for every particular data feed.
    public var exchangeSaleConditions: String?
    /// Gets or sets implementation-specific flags.
    /// **Do not use this method directly**.
    var flags: Int32 = 0
    /// Gets or sets buyer of this time and sale event.
    public var buyer: String?
    /// Gets or sets seller of this time and sale event.
    public var seller: String?

    // TTE (TradeThroughExempt) values are ASCII chars in [0, 255].
    internal static let tteMask = 0xff
    internal static let tteShift = 8

    // SIDE values are taken from Side enum.
    internal static let sideMask = 3
    internal static let sideShift = 5

    internal static let spreadLeg = 1 << 4
    internal static let eth = 1 << 3
    internal static let validTick = 1 << 2

    // TYPE values are taken from TimeAndSaleType enum.
    internal static let typeMask = 3
    internal static let typeShift = 0

    /// Override var from ``IIndexedEvent``
    public var eventSource = IndexedEventSource.defaultSource
    /// Override var from ``IIndexedEvent``
    public var eventFlags: Int32 = 0
    /// Override var from ``IIndexedEvent``
    public var index: Long = 0

    init(_ symbol: String) {
        super.init(type: .timeAndSale)
        self.eventSymbol = symbol
    }

    public var description: String {
        """
DXFG_TIME_AND_SALE_T \
eventSymbol: \(eventSymbol) \
eventTime: \(eventTime) \
eventFlags: \(eventFlags), \
index: \(index), \
timeNanoPart: \(timeNanoPart), \
exchangeCode: \(exchangeCode), \
price: \(price), \
size: \(size), \
bidPrice: \(bidPrice), \
askPrice: \(askPrice), \
exchangeSaleConditions: \(exchangeSaleConditions ?? "null"), \
flags: \(flags), \
buyer: \(buyer ?? "null"), \
seller: \(seller ?? "null")
"""
    }

    /// Returns string representation of this time and sale event.
    public override func toString() -> String {
        return """
TimeAndSale{\(eventSymbol), \
eventTime=\((try? DXTimeFormat.defaultTimeFormat?.withMillis?.format(value: eventTime)) ?? ""), \
eventFlags=\(eventFlags.toHexString()), \
time=\((try? DXTimeFormat.defaultTimeFormat?.withMillis?.format(value: time))  ?? ""), \
timeNanoPart=\(timeNanoPart), \
sequence=\(getSequence()), \
exchange=\(StringUtil.encodeChar(char: exchangeCode)), \
price=\(price), \
size=\(size), \
bid=\(bidPrice), \
ask=\(askPrice), \
ESC='\(exchangeSaleConditions ?? "null")', \
TTE=\(StringUtil.encodeChar(char: Int16(getTradeThroughExempt().unicodeScalars.first?.value ?? 0))), \
side=\(aggressorSide), \
spread=\(isSpreadLeg), \
ETH=\(isExtendedTradingHours), \
validTick=\(isValidTick), \
type=\(timeAndSaleType)\
\(buyer == nil ? "" : ", buyer='\(buyer ?? "null")'")\
\(seller == nil ? "" : ", seller='\(seller ?? "null")'")\
}
"""
    }
}

extension TimeAndSale {
    /// Gets sequence number of this event to distinguish events that have the same ``time``.
    /// This sequence number does not have to be unique and
    /// does not need to be sequential. Sequence can range from 0 to ``MarketEventConst/maxSequence``.
    public func getSequence() -> Int {
        return Int(index) & Int(MarketEventConst.maxSequence)
    }

    /// Sets sequence number of this event to distinguish events that have the same ``time``.
    /// This sequence number does not have to be unique and
    /// does not need to be sequential. Sequence can range from 0 to ``MarketEventConst/maxSequence``.
    ///
    /// - Throws: ``ArgumentException/exception(_:)``
    public func setSequence(_ sequence: Int) throws {
        if sequence < 0 || sequence > MarketEventConst.maxSequence {
            throw ArgumentException.exception(
                "Sequence(\(sequence) is < 0 or > MaxSequence(\(MarketEventConst.maxSequence)"
            )
        }
        index = (index & ~Long(MarketEventConst.maxSequence)) | Long(sequence)

    }

    /// Gets or sets timestamp of the original event.
    /// 
    /// Time is measured in milliseconds between the current time and midnight, January 1, 1970 UTC.
    public var time: Int64 {
        get {
            Int64(((self.index >> 32) * 1000) + ((self.index >> 22) & 0x3ff))
        }
        set {
            index = (Long(TimeUtil.getSecondsFromTime(newValue)) << 32) |
            Long((TimeUtil.getMillisFromTime(newValue)) << 22) | Long(getSequence())
        }
    }

    /// Gets or sets timestamp of the original event in nanoseconds.
    ///
    /// Time is measured in nanoseconds between the current time and midnight, January 1, 1970 UTC.
    public var timeNanos: Int64 {
        get {
            TimeNanosUtil.getNanosFromMillisAndNanoPart(time, timeNanoPart)
        }
        set {
            time = TimeNanosUtil.getNanoPartFromNanos(newValue)
            timeNanoPart = Int32(TimeNanosUtil.getNanoPartFromNanos(newValue))
        }
    }
    /// Gets  TradeThroughExempt flag of this time and sale event.
    public func getTradeThroughExempt() -> Character {
        Character(BitUtil.getBits(flags: Int(flags),
                                  mask: TimeAndSale.tteMask,
                                  shift: TimeAndSale.tteShift))
    }
    /// Sets  TradeThroughExempt flag of this time and sale event.
    ///
    /// - Throws: ``ArgumentException/exception(_:)``
    public func setTradeThroughExempt(_ char: Character) throws {
        try StringUtil.checkChar(char: char, mask: TimeAndSale.tteMask, name: "tradeThroughExempt")
        if let value = char.unicodeScalars.first?.value {
            flags = Int32(BitUtil.setBits(flags: Int(flags),
                                          mask: TimeAndSale.tteMask,
                                          shift: TimeAndSale.tteShift,
                                          bits: Int(value)))
        }
    }

    /// Gets or sets aggressor side of this time and sale event.
    public var aggressorSide: Side {
        get {
            Side.valueOf(Int(BitUtil.getBits(flags: Int(flags),
                                             mask: TimeAndSale.sideMask,
                                             shift: TimeAndSale.sideShift)))
        }
        set {
            flags = Int32(BitUtil.setBits(flags: Int(flags),
                                          mask: TimeAndSale.sideMask,
                                          shift: TimeAndSale.sideShift,
                                          bits: newValue.rawValue))
        }
    }

    /// Gets or sets a value indicating whether this event represents a spread leg.
    public var isSpreadLeg: Bool {
        get {
            (flags & Int32(TimeAndSale.spreadLeg)) != 0
        }
        set {
            flags = newValue ? (flags | Int32(TimeAndSale.spreadLeg)) : (flags & ~Int32(TimeAndSale.spreadLeg))
        }
    }

    /// Gets or sets a value indicating whether this event represents an extended trading hours sale.
    public var isExtendedTradingHours: Bool {
        get {
            (flags & Int32(TimeAndSale.eth)) != 0
        }
        set {
            flags = newValue ? (flags | Int32(TimeAndSale.eth)) : (flags & ~Int32(TimeAndSale.eth))
        }
    }

    /// Gets or sets a value indicating whether this event represents a valid intraday tick.
    ///
    /// Note, that a correction for a previously distributed valid tick represents a new valid tick itself,
    /// but a cancellation of a previous valid tick does not.
    public var isValidTick: Bool {
        get {
            (flags & Int32(TimeAndSale.validTick)) != 0
        }
        set {
            flags = newValue ? (flags | Int32(TimeAndSale.validTick)) : flags & ~Int32(TimeAndSale.validTick)
        }
    }

    /// Gets or sets type of this time and sale event.
    public var timeAndSaleType: TimeAndSaleType {
        get {
            TimeAndSaleType.valueOf(BitUtil.getBits(flags: Int(flags),
                                                    mask: TimeAndSale.typeMask,
                                                    shift: TimeAndSale.typeShift))
        }
        set {
            flags = Int32(BitUtil.setBits(flags: Int(flags),
                                          mask: TimeAndSale.typeMask,
                                          shift: TimeAndSale.typeShift,
                                          bits: newValue.rawValue))
        }
    }

    /// Gets a value indicating whether this is a new event (not cancellation or correction).
    ///
    /// It is true for newly created time and sale event.
    public var isNew: Bool {
        timeAndSaleType == .new
    }

    /// Gets a value indicating whether this is a correction of a previous event.
    ///
    /// It is false for newly created time and sale event.
    /// true if this is a correction of a previous event.
    public var isCorrection: Bool {
        timeAndSaleType == .correction
    }

    /// Gets a value indicating whether this is a cancellation of a previous event.
    ///
    /// It is false for newly created time and sale event.
    /// true if this is a cancellation of a previous event.
    public var isCancel: Bool {
        timeAndSaleType == .cancel
    }

}
