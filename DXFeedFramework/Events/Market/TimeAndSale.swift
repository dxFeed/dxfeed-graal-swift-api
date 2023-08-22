//
//  TimeAndSale.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 06.06.23.
//

import Foundation

public class TimeAndSale: MarketEvent, ITimeSeriesEvent, CustomStringConvertible {
    public let type: EventCode = .timeAndSale
    public var eventSymbol: String
    public var eventTime: Int64 = 0

    public var timeNanoPart: Int32 = 0
    public var exchangeCode: Int16 = 0
    public var price: Double = .nan
    public var size: Double = .nan
    public var bidPrice: Double = .nan
    public var askPrice: Double = .nan
    public var exchangeSaleConditions: String?
    public var flags: Int32 = 0
    public var buyer: String?
    public var seller: String?

    // TTE (TradeThroughExempt) values are ASCII chars in [0, 255].
    internal let tteMask = 0xff
    internal let tteShift = 8

    // SIDE values are taken from Side enum.
    internal let sideMask = 3
    internal let sideShift = 5

    internal let spreadLeg = 1 << 4
    internal let eth = 1 << 3
    internal let validTick = 1 << 2

    // TYPE values are taken from TimeAndSaleType enum.
    internal let typeMask = 3
    internal let typeShift = 0

    public var eventSource = IndexedEventSource.defaultSource
    public var eventFlags: Int32 = 0
    public var index: Long = 0

    init(_ symbol: String) {
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
}

extension TimeAndSale {
    public func getSequence() -> Int {
        return Int(index) & Int(MarketEventConst.maxSequence)
    }

    public func setSequence(_ sequence: Int) throws {
        if sequence < 0 || sequence > MarketEventConst.maxSequence {
            throw ArgumentException.exception(
                "Sequence(\(sequence) is < 0 or > MaxSequence(\(MarketEventConst.maxSequence)"
            )
        }
        index = (index & ~Long(MarketEventConst.maxSequence)) | Long(sequence)

    }

    public var time: Int64 {
        get {
            Int64(((self.index >> 32) * 1000) + ((self.index >> 22) & 0x3ff))
        }
        set {
            index = (Long(TimeUtil.getSecondsFromTime(newValue)) << 32) |
            Long((TimeUtil.getMillisFromTime(newValue)) << 22) | Long(getSequence())
        }
    }
    public var timeNanos: Int64 {
        get {
            TimeNanosUtil.getNanosFromMillisAndNanoPart(time, timeNanoPart)
        }
        set {
            time = TimeNanosUtil.getNanoPartFromNanos(newValue)
            timeNanoPart = Int32(TimeNanosUtil.getNanoPartFromNanos(newValue))
        }
    }

    public func getTradeThroughExempt() -> Character {
        Character(BitUtil.getBits(flags: Int(flags), mask: tteMask, shift: tteShift))
    }

    public func setTradeThroughExempt(_ char: Character) throws {
        try StringUtil.checkChar(char: char, mask: tteMask, name: "tradeThroughExempt")
        if let value = char.unicodeScalars.first?.value {
            flags = Int32(BitUtil.setBits(flags: Int(flags), mask: tteMask, shift: tteShift, bits: Int(value)))
        }
    }

    public var aggressorSide: Side {
        get {
            Side.valueOf(Int(BitUtil.getBits(flags: Int(flags), mask: sideMask, shift: sideShift)))
        }
        set {
            flags = Int32(BitUtil.setBits(flags: Int(flags), mask: sideMask, shift: sideShift, bits: newValue.rawValue))
        }
    }

    public var isSpreadLeg: Bool {
        get {
            (flags & Int32(spreadLeg)) != 0
        }
        set {
            flags = newValue ? (flags | Int32(spreadLeg)) : (flags & ~Int32(spreadLeg))
        }
    }

    public var isExtendedTradingHours: Bool {
        get {
            (flags & Int32(eth)) != 0
        }
        set {
            flags = newValue ? (flags | Int32(eth)) : (flags & ~Int32(eth))
        }
    }

    public var isValidTick: Bool {
        get {
            (flags & Int32(validTick)) != 0
        }
        set {
            flags = newValue ? (flags | Int32(validTick)) : flags & ~Int32(validTick)
        }
    }

    public var timeAndSaleType: TimeAndSaleType {
        get {
            TimeAndSaleType.valueOf(BitUtil.getBits(flags: Int(flags), mask: typeMask, shift: typeShift))
        }
        set {
            flags = Int32(BitUtil.setBits(flags: Int(flags), mask: typeMask, shift: typeShift, bits: newValue.rawValue))
        }
    }

    public var isNew: Bool {
        timeAndSaleType == .new
    }

    public var isCorrection: Bool {
        timeAndSaleType == .correction
    }

    public var isCancel: Bool {
        timeAndSaleType == .cancel
    }

    func toString() -> String {
        return """
TimeAndSale{"\(eventSymbol), \
eventTime=\(TimeUtil.toLocalDateString(millis: eventTime)), \
eventFlags=0x\(String(format: "%02X", eventFlags)), \
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
type=\(timeAndSaleType)\(buyer == nil ? "" : ", buyer='\(buyer ?? "null")'")\
        \(seller == nil ? "" : ", seller='\(seller ?? "null")'")\
}
"""
    }
}
