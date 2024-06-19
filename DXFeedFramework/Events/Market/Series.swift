//
//  Series.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 12.10.23.
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
    public var type: EventCode = .series

    public var eventSource: IndexedEventSource = .defaultSource

    public var eventFlags: Int32 = 0

    public var index: Long = 0

    public var eventSymbol: String

    public var eventTime: Int64 = 0

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
    /// Change ``time`` and/or  ``sequence``
    public private(set) var timeSequence: Long = 0
    /// Gets or sets day id of expiration.
    public let expiration: Int32 = 0
    /// Gets or sets implied volatility index for this series based on VIX methodology.
    public let volatility: Double = .nan
    /// Gets or sets call options traded volume for a day.
    public let callVolume: Double = .nan
    /// Gets or sets put options traded volume for a day.
    public let putVolume: Double = .nan
    /// Gets or sets ratio of put options traded volume to call options traded volume for a day.
    public let putCallRatio: Double = .nan
    /// Gets or sets implied forward price for this option series.
    public let forwardPrice: Double = .nan
    /// Gets or sets implied simple dividend return of the corresponding option series.
    public let dividend: Double = .nan
    /// Gets or sets implied simple interest return of the corresponding option series.
    public let interest: Double = .nan

    public init(_ eventSymbol: String) {
        self.eventSymbol = eventSymbol
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
        return callVolume.isNaN ? putVolume : putVolume + putVolume;
    }

    public func toString() -> String {
        return
"""
Series{\(eventSymbol), \
eventTime=\(TimeUtil.toLocalDateString(millis: eventTime)), \
eventFlags=0x\(String(format: "%02X", eventFlags)), \
index=0x\(String(format: "%02X", index)), \
time=\(TimeUtil.toLocalDateString(millis: time)), \
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
