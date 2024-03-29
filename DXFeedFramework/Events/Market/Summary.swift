//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

/// Summary information snapshot about the trading session including session highs, lows, etc.
///
/// It represents the most recent information that is available about the trading session in
/// the market at any given moment of time.
///
/// This event is implemented on top of QDS records 
///  for regional exchange trading session summaries.
///
/// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/market/Summary.html)
public class Summary: MarketEvent, ILastingEvent, CustomStringConvertible {
    public class override var type: EventCode { .summary }

    /*
     * Flags property has several significant bits that are packed into an integer in the following way:
     *   31..4     3    2    1    0
     *) \--------+----+----+----+----+
     * |        |  Close  |PrevClose|
     *) \--------+----+----+----+----+
     */

    // PRICE_TYPE values are taken from PriceType enum.
    static let dayClosePriceTypeMask: Int32 = 3
    static let dayClosePriceTypeShift: Int32 = 2

    // priceType values are taken from pricetype enum.
    static let prevDayClosePriceTypeMask: Int32 = 3
    static let prevDayClosePriceTypeShift: Int32 = 0

    /// Gets or sets identifier of the day that this summary represents.
    /// Identifier of the day is the number of days passed since January 1, 1970.
    public var dayId: Int32 = 0
    /// Gets or sets  the first (open) price for the day.
    public var dayOpenPrice: Double = .nan
    /// Gets or sets the maximal (high) price for the day.
    public var dayHighPrice: Double = .nan
    /// Gets or sets the minimal (low) price for the day.
    public var dayLowPrice: Double = .nan
    /// Gets or sets he last (close) price for the day.
    public var dayClosePrice: Double = .nan
    /// Gets or sets  identifier of the previous day that this summary represents.
    /// Identifier of the day is the number of days passed since January 1, 1970.
    public var prevDayId: Int32 = 0
    /// Gets or sets the price type of the last (close) price for the day.
    public var prevDayClosePrice: Double = .nan
    /// Gets or sets total volume traded for the previous day.
    public var prevDayVolume: Double = .nan
    /// Gets or sets open interest of the symbol as the number of open contracts.
    public var openInterest: Long = 0
    /// Gets or sets implementation-specific flags.
    var flags: Int32 = 0

    /// Initializes a new instance of the ``Summary`` class.
    public init(_ eventSymbol: String) {
        super.init()
        self.eventSymbol = eventSymbol
    }

    public var description: String {
"""
DXFG_SUMMARY_T \
eventSymbol: \(eventSymbol) \
eventTime: \(eventTime) \
dayId: \(dayId), \
dayOpenPrice: \(dayOpenPrice), \
dayHighPrice: \(dayHighPrice), \
dayLowPrice: \(dayLowPrice), \
dayClosePrice: \(dayClosePrice), \
prevDayId: \(prevDayId), \
prevDayClosePrice: \(prevDayClosePrice), \
prevDayVolume: \(prevDayVolume), \
openInterest: \(openInterest), \
flags: \(flags)
"""
    }

    /// Returns string representation of this summary fields.
    public override func toString() -> String {
        return
"""
Summary{\(eventSymbol), \
eventTime=\((try? DXTimeFormat.defaultTimeFormat?.withMillis?.format(value: eventTime)) ?? ""), \
day=\(DayUtil.getYearMonthDayByDayId(dayId)), \
dayOpen=\(dayOpenPrice), \
dayHigh=\(dayHighPrice), \
dayLow=\(dayLowPrice), \
dayClose=\(dayClosePrice), \
dayCloseType=\(dayClosePriceType), \
prevDay=\(DayUtil.getYearMonthDayByDayId(prevDayId)), \
prevDayClose=\(prevDayClosePrice), \
prevDayCloseType=\(prevDayClosePriceType), \
prevDayVolume=\(prevDayVolume), \
openInterest=\(openInterest), \
}
"""
    }
}

extension Summary {
    /// Gets or sets the price type of the last (close) price for the day.
    public var dayClosePriceType: PriceType {
        get {
            PriceType.valueOf(Int(BitUtil.getBits(flags: flags,
                                                  mask: Summary.dayClosePriceTypeMask,
                                                  shift: Summary.dayClosePriceTypeShift)))
        }
        set {
            flags = BitUtil.setBits(flags: flags,
                                    mask: Summary.dayClosePriceTypeMask,
                                    shift: Summary.dayClosePriceTypeShift,
                                    bits: Int32(newValue.rawValue.code))
        }
    }
    /// Gets or sets the price type of the last (close) price for the previous day.
    public var prevDayClosePriceType: PriceType {
        get {
            PriceType.valueOf(Int(BitUtil.getBits(flags: flags,
                                                  mask: Summary.prevDayClosePriceTypeMask,
                                                  shift: Summary.prevDayClosePriceTypeShift)))
        }
        set {
            flags = BitUtil.setBits(flags: flags,
                                    mask: Summary.prevDayClosePriceTypeMask,
                                    shift: Summary.prevDayClosePriceTypeShift,
                                    bits: Int32(newValue.rawValue.code))
        }
    }

}
