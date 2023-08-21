//
//  TimeAndSale.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 06.06.23.
//

import Foundation

public class TimeAndSale: MarketEvent, CustomStringConvertible {
    public let type: EventCode = .timeAndSale
    public var eventSymbol: String
    public var eventTime: Int64 = 0

    public var eventFlags: Int32 = 0
    public var index: Long = 0
    public var timeNanoPart: Int32 = 0
    public var exchangeCode: Int16 = 0
    public var price: Double = .nan
    public var size: Double = .nan
    public var bidPrice: Double = .nan
    public var askPrice: Double = .nan
    public var exchangeSaleConditions: String = ""
    public var flags: Int32 = 0
    public var buyer: String = ""
    public var seller: String = ""

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
exchangeSaleConditions: \(exchangeSaleConditions), \
flags: \(flags), \
buyer: \(buyer), \
seller: \(seller)
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
            Long((TimeUtil.getMillisFromTime(newValue) << 22)) | Long(getSequence())
        }
    }
}
