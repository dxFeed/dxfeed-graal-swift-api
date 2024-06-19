//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

/// Underlying event is a snapshot of computed values that are available for an option underlying
/// symbol based on the option prices on the market.
///
/// It represents the most recent information that is available about the corresponding values on
/// the market at any given moment of time.
///
/// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/option/Underlying.html)
public class Underlying: MarketEvent, ITimeSeriesEvent, ILastingEvent, CustomStringConvertible {
    public var type: EventCode = .underlying

    public var eventSymbol: String

    public var eventTime: Int64 = 0

    public var eventSource: IndexedEventSource = .defaultSource

    public var eventFlags: Int32 = 0

    public var index: Long = 0

    /*
     * EventFlags property has several significant bits that are packed into an integer in the following way:
     *    31..7    6    5    4    3    2    1    0
     * +---------+----+----+----+----+----+----+----+
     * |         | SM |    | SS | SE | SB | RE | TX |
     * +---------+----+----+----+----+----+----+----+
     */

    /// Gets or sets 30-day implied volatility for this underlying based on VIX methodology.
    public var volatility: Double = .nan
    /// Gets or sets front month implied volatility for this underlying based on VIX methodology.
    public var frontVolatility: Double = .nan
    /// Gets or sets back month implied volatility for this underlying based on VIX methodology.
    public var backVolatility: Double = .nan
    /// Gets or sets call options traded volume for a day.
    public var callVolume: Double = .nan
    /// Gets or sets put options traded volume for a day.
    public var putVolume: Double = .nan
    /// Gets or sets ratio of put options traded volume to call options traded volume for a day.
    public var putCallRatio: Double = .nan

    public init(_ eventSymbol: String) {
        self.eventSymbol = eventSymbol
    }

    public var description: String {
"""
DXFG_UNDERLYING_T \
eventSymbol: \(eventSymbol) \
eventTime: \(eventTime) \
eventFlags: \(eventFlags), \
index: \(index), \
volatility: \(volatility), \
frontVolatility: \(frontVolatility), \
backVolatility: \(backVolatility), \
callVolume: \(callVolume), \
putVolume: \(putVolume), \
putCallRatio: \(putCallRatio)
"""
        }
}

extension Underlying {
    /// Gets or sets timestamp of the event in milliseconds.
    /// Time is measured in milliseconds between the current time and midnight, January 1, 1970 UTC.
    public var time: Long {
        get {
            ((index >> 32) * 1000) + ((index >> 22) & 0x3ff)
        }
        set {
            index = Long(TimeUtil.getSecondsFromTime(newValue) << 32) |
            (Long(TimeUtil.getMillisFromTime(newValue)) << 22) |
            Int64(getSequence())
        }
    }
    /// Gets options traded volume for a day.
    public var optionVolume: Double {
        if putVolume.isNaN {
            return callVolume
        }
        return callVolume.isNaN ? putVolume : putVolume + callVolume
    }
    /// Gets sequence number of this quote to distinguish events that have the same ``time``.
    /// This sequence number does not have to be unique and
    /// does not need to be sequential. Sequence can range from 0 to ``MarketEventConst/maxSequence``.
    public func getSequence() -> Int {
        return Int(index) & Int(MarketEventConst.maxSequence)
    }
    /// Sets sequence number of this quote to distinguish quotes that have the same ``time``.
    /// This sequence number does not have to be unique and
    /// does not need to be sequential. Sequence can range from 0 to ``MarketEventConst/maxSequence``.
    /// - Throws: ``ArgumentException/exception(_:)``
    public func setSequence(_ sequence: Int) throws {
        if sequence < 0 || sequence > MarketEventConst.maxSequence {
            throw ArgumentException.exception(
                "Sequence(\(sequence) is < 0 or > MaxSequence(\(MarketEventConst.maxSequence)"
            )
        }
        index = Long(index & ~Long(MarketEventConst.maxSequence)) | Long(sequence)
    }
    /// Returns string representation of this underlying fields.
    public func toString() -> String {
        return """
Underlying{"\(eventSymbol) \
eventTime=\((try? DXTimeFormat.defaultTimeFormat?.withMillis?.format(value: eventTime)) ?? ""), \
eventFlags=\(eventFlags.toHexString()), \
time=\((try? DXTimeFormat.defaultTimeFormat?.withMillis?.format(value: time)) ?? ""), \
sequence=\(self.getSequence()), \
volatility=\(volatility), \
frontVolatility=\(frontVolatility), \
backVolatility=\(backVolatility), \
callVolume=\(callVolume), \
putVolume=\(putVolume), \
putCallRatio=\(putCallRatio)}
"""
    }
}
