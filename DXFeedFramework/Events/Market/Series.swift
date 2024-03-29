//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

/// Series event is a snapshot of computed values that are available for all option series for
/// a given underlying symbol based on the option prices on the market.
///
/// It represents the most recent information that is available about the corresponding values on
/// the market at any given moment of time.
///
/// (For more details see)[https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/option/Series.html]
public class Series: MarketEvent, IIndexedEvent {
    public class override var type: EventCode { .series }

    public var eventSource: IndexedEventSource = .defaultSource

    public var eventFlags: Int32 = 0

    public var index: Long = 0

    /*
     * EventFlags property has several significant bits that are packed into an integer in the following way:
     *    31..7    6    5    4    3    2    1    0
     * \---------+----+----+----+----+----+----+----+
     * |         | SM |    | SS | SE | SB | RE | TX |
     * \---------+----+----+----+----+----+----+----+
     */

    /// Gets or sets time and sequence of this series packaged into single long value.
    ///
    /// This method is intended for efficient series time priority comparison.
    /// **Do not use this method directly**
    /// 
    /// Change ``time`` and/or  ``setSequence(_:)``
    public internal(set) var timeSequence: Long = 0
    /// Gets or sets day id of expiration.
    public var expiration: Int32 = 0
    /// Gets or sets implied volatility index for this series based on VIX methodology.
    public var volatility: Double = .nan
    /// Gets or sets call options traded volume for a day.
    public var callVolume: Double = .nan
    /// Gets or sets put options traded volume for a day.
    public var putVolume: Double = .nan
    /// Gets or sets ratio of put options traded volume to call options traded volume for a day.
    public var putCallRatio: Double = .nan
    /// Gets or sets implied forward price for this option series.
    public var forwardPrice: Double = .nan
    /// Gets or sets implied simple dividend return of the corresponding option series.
    public var dividend: Double = .nan
    /// Gets or sets implied simple interest return of the corresponding option series.
    public var interest: Double = .nan

    public init(_ eventSymbol: String) {
        super.init()
        self.eventSymbol = eventSymbol
    }

    /// Returns string representation of this candle event.
    public override func toString() -> String {
        return
"""
Series{\(eventSymbol), \
eventTime=\((try? DXTimeFormat.defaultTimeFormat?.withMillis?.format(value: eventTime)) ?? ""), \
eventFlags=\(eventFlags.toHexString()), \
index=\(index.toHexString()), \
time=\((try? DXTimeFormat.defaultTimeFormat?.withMillis?.format(value: time)) ?? ""), \
sequence=\(self.getSequence()), \
expiration=\(DayUtil.getYearMonthDayByDayId(Int(expiration))), \
volatility=\(volatility), \
callVolume=\(callVolume), \
putVolume=\(putVolume), \
putCallRatio=\(putCallRatio), \
forwardPrice=\(forwardPrice), \
dividend=\(dividend), \
interest=\(interest)
"""
    }
}

extension Series {
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
    /// Gets sequence number of this event to distinguish events that have the same ``time``.
    /// This sequence number does not have to be unique and
    /// does not need to be sequential. Sequence can range from 0 to ``MarketEventConst/maxSequence``.
    public func getSequence() -> Int {
        return Int(timeSequence) & Int(MarketEventConst.maxSequence)
    }
    /// Sets sequence number of this event to distinguish quotes that have the same ``time``.
    /// This sequence number does not have to be unique and
    /// does not need to be sequential. Sequence can range from 0 to ``MarketEventConst/maxSequence``.
    /// - Throws: ``ArgumentException/exception(_:)``
    public func setSequence(_ sequence: Int) throws {
        if sequence < 0 || sequence > MarketEventConst.maxSequence {
            throw ArgumentException.exception(
                "Sequence(\(sequence) is < 0 or > MaxSequence(\(MarketEventConst.maxSequence)"
            )
        }
        timeSequence = Long(timeSequence & ~Long(MarketEventConst.maxSequence)) | Long(sequence)
    }

    /// Gets options traded volume for a day.
    public func getOptionVolume() -> Double {
        if putVolume.isNaN {
            return callVolume
        }
        return callVolume.isNaN ? putVolume : putVolume + putVolume
    }

}
