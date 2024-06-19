//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

/// Theo price is a snapshot of the theoretical option price computation that is
/// periodically performed by http://www.devexperts.com/en/products/price.html
///
/// model-free computation.
/// It represents the most recent information that is available about the corresponding
/// values at any given moment of time.
/// The values include first and second order derivative of the price curve by price, so that
/// the real-time theoretical option price can be estimated on real-time changes of the underlying
/// price in the vicinity.
///
/// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/option/TheoPrice.html)
public class TheoPrice: MarketEvent, ITimeSeriesEvent, ILastingEvent, CustomStringConvertible {

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

    /// Gets or sets theoretical option price.
    public var price: Double = .nan
    /// Gets or sets underlying price at the time of theo price computation.
    public var underlyingPrice: Double = .nan
    /// Gets or sets delta of the theoretical price.
    /// Delta is the first derivative of an option price by an underlying price.
    public var delta: Double = .nan
    /// Gets or sets gamma of the theoretical price.
    /// Gamma is the second derivative of an option price by an underlying price.
    public var gamma: Double = .nan
    /// Gets or sets implied simple dividend return of the corresponding option series.
    public var dividend: Double = .nan
    /// Gets or sets implied simple interest return of the corresponding option series.
    public var interest: Double = .nan

    public init(_ eventSymbol: String) {
        super.init(type: .theoPrice)
        self.eventSymbol = eventSymbol
    }

    public var description: String {
"""
DXFG_THEO_PRICE_T \
eventSymbol: \(eventSymbol) \
eventTime: \(eventTime) \
eventFlags: \(eventFlags), \
index: \(index), \
price: \(price), \
underlyingPrice: \(underlyingPrice), \
delta: \(delta), \
gamma: \(gamma), \
dividend: \(dividend), \
interest: \(interest)
"""
        }

    /// Returns string representation of this order fields.
    public override func toString() -> String {
        return """
TheoPrice{\(eventSymbol) \
eventTime=\((try? DXTimeFormat.defaultTimeFormat?.withMillis?.format(value: eventTime)) ?? ""), \
eventFlags=\(eventFlags.toHexString()), \
time=\((try? DXTimeFormat.defaultTimeFormat?.withMillis?.format(value: time)) ?? ""), \
sequence=\(self.getSequence()), \
price=\(price) \
underlyingPrice=\(underlyingPrice), \
delta=\(delta), \
gamma=\(gamma), \
dividend=\(dividend), \
interest=\(interest), \
}
"""
    }
}

extension TheoPrice {
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
    /// Returns string representation of this order fields.
    public func toString() -> String {
        return """
TheoPrice{\(eventSymbol) \
eventTime=\((try? DXTimeFormat.defaultTimeFormat?.withMillis?.format(value: eventTime)) ?? ""), \
eventFlags=\(eventFlags.toHexString()), \
time=\((try? DXTimeFormat.defaultTimeFormat?.withMillis?.format(value: time)) ?? ""), \
sequence=\(self.getSequence()), \
price=\(price) \
underlyingPrice=\(underlyingPrice), \
delta=\(delta), \
gamma=\(gamma), \
dividend=\(dividend), \
interest=\(interest), \
}
"""
    }
}
