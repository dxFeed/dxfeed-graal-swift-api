//
//  OptionSale.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 13.10.23.
//

import Foundation

/// Option Sale event represents a trade or another market event with the price
/// (for example, market open/close price, etc.) for each option symbol listed under the specified Underlying.
///
/// Option Sales are intended to provide information about option trades **in a continuous time slice** with
/// the additional metrics, like Option Volatility, Option Delta, and Underlying Price.
///
/// Option Sale events have unique ``index``
/// which can be used for later correction/cancellation processing.
///
/// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/market/OptionSale.html)
public class OptionSale: MarketEvent, IIndexedEvent {
    public var type: EventCode = .optionSale

    public var eventSource: IndexedEventSource = .defaultSource

    public var eventFlags: Int32 = 0

    public var index: Long = 0

    public var eventSymbol: String

    public var eventTime: Int64 = 0

    /*
     * EventFlags property has several significant bits that are packed into an integer in the following way:
     *    31..7    6    5    4    3    2    1    0
     * +--------+----+----+----+----+----+----+----+
     * |        | SM |    | SS | SE | SB | RE | TX |
     * +--------+----+----+----+----+----+----+----+
     */

    /// Gets or sets time and sequence of this series packaged into single long value.
    ///
    /// This method is intended for efficient series time priority comparison.
    /// **Do not use this method directly**
    /// Change ``time`` and/or  ``setSequence(_:)``
    public var timeSequence: Int64 = 0
    /// Gets or sets microseconds and nanoseconds time part of event.
    public var timeNanoPart: Int32 = 0
    /// Gets or sets exchange code of this option sale event.
    public var exchangeCode: Int16 = 0
    /// Gets or sets price of this option sale event.
    public var price: Double = .nan
    /// Gets or sets size this option sale event as floating number with fractions.
    public var size: Double = .nan
    /// Gets or sets the current bid price on the market when this option sale event had occurred.
    public var bidPrice: Double = .nan
    /// Gets or sets the current ask price on the market when this option sale event had occurred.
    public var askPrice: Double = .nan
    /// Gets or sets sale conditions provided for this event by data feed.
    ///
    /// This field format is specific for every particular data feed.
    public var exchangeSaleConditions: String = ""
    /// Gets or sets implementation-specific flags.
    ///
    /// **Do not use this method directly.**
    public var flags: Int32 = 0
    /// Gets or sets underlying price at the time of this option sale event.
    public var underlyingPrice: Double = .nan
    /// Gets or sets Black-Scholes implied volatility of the option at the time of this option sale event.
    public var volatility: Double = .nan
    /// Gets or sets option delta at the time of this option sale event.
    /// Delta is the first derivative of an option price by an underlying price.
    public var delta: Double = .nan
    /// Gets or sets option symbol of this event.
    public var optionSymbol: String = ""

    public init(_ eventSymbol: String) {
        self.eventSymbol = eventSymbol
    }
}

extension OptionSale {
    /// Gets or sets timestamp of the event in milliseconds.
    /// Time is measured in milliseconds between the current time and midnight, January 1, 1970 UTC.
    public var time: Long {
        get {
            ((timeSequence >> 32) * 1000) + ((timeSequence >> 22) & 0x3ff)
        }
        set {
            timeSequence = Long(TimeUtil.getSecondsFromTime(newValue) << 32) |
            (Long(TimeUtil.getMillisFromTime(newValue)) << 22) |
            Int64(getSequence())
        }
    }

    /// Gets or sets time of the last trade in nanoseconds.
    /// Time is measured in nanoseconds between the current time and midnight, January 1, 1970 UTC.
    public var timeNanos: Long {
        get {
            TimeNanosUtil.getNanosFromMillisAndNanoPart(time, timeNanoPart)
        }
        set {
            time = TimeNanosUtil.getNanoPartFromNanos(newValue)
            timeNanoPart = Int32(TimeNanosUtil.getNanoPartFromNanos(newValue))
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

    /// Gets  TradeThroughExempt flag of this option sale event.
    public func getTradeThroughExempt() -> Character {
        Character(BitUtil.getBits(flags: Int(flags),
                                  mask: TimeAndSale.tteMask,
                                  shift: TimeAndSale.tteShift))
    }
    /// Sets  TradeThroughExempt flag of this option sale event.
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

    /// Gets or sets aggressor side of this option sale event.
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

    /// Gets or sets type of this option sale event.
    public var optionSaleType: TimeAndSaleType {
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
    /// It is true for newly created option sale event.
    public var isNew: Bool {
        optionSaleType == .new
    }

    /// Gets a value indicating whether this is a correction of a previous event.
    ///
    /// It is false for newly created option sale event.
    /// true if this is a correction of a previous event.
    public var isCorrection: Bool {
        optionSaleType == .correction
    }

    /// Gets a value indicating whether this is a cancellation of a previous event.
    ///
    /// It is false for newly created option sale event.
    /// true if this is a cancellation of a previous event.
    public var isCancel: Bool {
        optionSaleType == .cancel
    }

    /// Returns string representation of this time and sale event.
    public func toString() -> String {
        return """
OptionSale{\(eventSymbol), \
eventTime=\(TimeUtil.toLocalDateString(millis: eventTime)), \
eventFlags=0x\(String(format: "%02X", eventFlags)), \
index=0x\(String(format: "%02X", index)), \
time=\(TimeUtil.toLocalDateString(millis: time)), \
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
type=\(optionSaleType), \
underlyingPrice=\(underlyingPrice), \
volatility=\(volatility), \
delta=\(delta), \
optionSymbol='\(optionSymbol)'\
}
"""
    }
}
