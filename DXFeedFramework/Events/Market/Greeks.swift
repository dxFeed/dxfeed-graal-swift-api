//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
/// Greeks event is a snapshot of the option price, Black-Scholes volatility and greeks.
///
/// It represents the most recent information that is available about the corresponding values on
/// the market at any given moment of time.
///
/// Some greeks sources provide a consistent view of the set of known greeks.
/// The corresponding information is carried in ``eventFlags`` property.
/// The logic behind this property is detailed in ``IIndexedEvent`` class documentation
///
/// Multiple event sources for the same symbol are not supported for greeks, thus
/// ``eventSource`` property is always ``IndexedEventSource/defaultSource``.
///
/// Publishing Greeks
/// Publishing of greeks events follows the general rules explained in ``ITimeSeriesEvent`` class
/// documentation.
///
/// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/option/Greeks.html)
public class Greeks: MarketEvent, ITimeSeriesEvent, ILastingEvent, CustomStringConvertible {
    public class override var type: EventCode { .greeks }

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
    /// Gets or sets option market price.
    public var price: Double = .nan
    /// Gets or sets Black-Scholes implied volatility of the option.
    public var volatility: Double = .nan
    /// Gets or sets option delta.
    /// Delta is the first derivative of an option price by an underlying price.
    public var delta: Double = .nan
    /// Gets or sets option gamma.
    /// Gamma is the second derivative of an option price by an underlying price.
    public var gamma: Double = .nan
    /// Gets or sets option theta.
    /// Theta is the first derivative of an option price by a number of days to expiration.
    public var theta: Double = .nan
    /// Gets or sets option rho.
    /// Rho is the first derivative of an option price by percentage interest rate.
    public var rho: Double = .nan
    /// Gets or sets vega.
    /// Vega is the first derivative of an option price by percentage volatility.
    public var vega: Double = .nan

    public init(_ eventSymbol: String) {
        super.init()
        self.eventSymbol = eventSymbol
    }

    public var description: String {
        """
DXFG_GREEKS_T \
eventSymbol: \(eventSymbol) \
eventTime: \(eventTime) \
eventFlags: \(eventFlags), \
index: \(index), \
price: \(price), \
volatility: \(volatility), \
delta: \(delta), \
gamma: \(gamma), \
theta: \(theta), \
rho: \(rho), \
vega: \(vega)
"""
    }

    /// Returns string representation of this greeks fields.
    public override func toString() -> String {
        return """
Greeks{\(eventSymbol), \
eventTime=\((try? DXTimeFormat.defaultTimeFormat?.withMillis?.format(value: eventTime)) ?? ""), \
eventFlags=\(eventFlags.toHexString()), \
time=\((try? DXTimeFormat.defaultTimeFormat?.withMillis?.format(value: time)) ?? ""), \
sequence=\(self.getSequence()), \
price=\(price), \
volatility=\(volatility), \
delta=\(delta), \
gamma=\(gamma), \
theta=\(theta), \
rho=\(rho), \
vega=\(vega)}
"""
    }
}

extension Greeks {
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

}
