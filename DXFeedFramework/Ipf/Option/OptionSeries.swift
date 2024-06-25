//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation


/// Series of call and put options with different strike sharing the same attributes of
///  expiration, last trading day, spc, multiplies, etc.
///
///  <T> The type of option instrument instances.
public class OptionSeries<T> {

    /// Day id of expiration.
    public internal(set) var expiration: Long
    /// Day id of last trading day.
    public internal(set) var lastTrade: Long
    /// Market value multiplier.
    public internal(set) var multiplier: Double
    /// Shares per contract for options.
    public internal(set) var spc: Double
    /// Additional underlyings for options, including additional cash.
    ///
    /// It shall use following format:
    ///     <VALUE> ::= <empty> | <LIST>
    ///     <LIST> ::= <AU> | <AU> <semicolon> <space> <LIST>
    ///     <AU> ::= <UNDERLYING> <space> <SPC>
    /// the list shall be sorted by <UNDERLYING>.
    /// Example: "SE 50", "FIS 53; US$ 45.46".
    public internal(set) var additionalUnderlyings: String
    /// Maturity month-year as provided for corresponding FIX tag (200).
    ///
    /// It can use several different formats depending on data source:
    ///
    /// YYYYMM – if only year and month are specified
    /// YYYYMMDD – if full date is specified
    /// YYYYMMwN – if week number (within a month) is specified
    public internal(set) var mmy: String
    /// Type of option.
    ///
    /// It shall use one of following values:
    /// STAN = Standard Options
    /// LEAP = Long-term Equity AnticiPation Securities
    /// SDO = Special Dated Options
    /// BINY = Binary Options
    /// FLEX = FLexible EXchange Options
    /// VSO = Variable Start Options
    /// RNGE = Range
    public internal(set) var optionType: String
    /// Expiration cycle style, such as "Weeklys", "Quarterlys".
    public internal(set) var expirationStyle: String
    /// Settlement price determination style, such as "Open", "Close".
    public internal(set) var settlementStyle: String
    /// Classification of Financial Instruments code of this option series.
    /// It shall use six-letter CFI code from ISO 10962 standard.
    /// It is allowed to use 'X' extensively and to omit trailing letters (assumed to be 'X').
    /// See [ISO 10962 on Wikipedia](http://en.wikipedia.org/wiki/ISO_10962)
    /// It starts with "OX" as both ``calls`` and ``putts`` are stored in a series.
    public internal(set) var cfi: String
    /// Dict of all calls from strike to a corresponding option instrument.
    public private(set) var  calls = [Double: T]()
    /// Dict of all puts from strike to a corresponding option instrument.
    public private(set) var putts = [Double: T]()
    
    private var strikes: [Double]?

    init() {
        expiration = 0
        lastTrade = 0
        multiplier = 0
        spc = 0
        additionalUnderlyings = ""
        mmy = ""
        optionType = ""
        expirationStyle = ""
        settlementStyle = ""
        cfi = ""
    }

    init(other: OptionSeries) {
        self.expiration = other.expiration
        self.lastTrade = other.lastTrade
        self.multiplier = other.multiplier
        self.spc = other.spc
        self.additionalUnderlyings = other.additionalUnderlyings
        self.mmy = other.mmy
        self.optionType = other.optionType
        self.expirationStyle = other.expirationStyle
        self.settlementStyle = other.settlementStyle
        self.cfi = other.cfi
    }

    /// Returns a shall copy of this option series.
    /// - Returns: a shall copy of this option series.
    public func clone() -> OptionSeries {
        let clone = OptionSeries.init(other: self)
        self.calls.forEach { key, value in
            clone.calls[key] = value
        }
        self.putts.forEach { key, value in
            clone.putts[key] = value
        }
        return clone
    }
    
    /// Returns a list of all strikes in ascending order.
    public func getStrikes() -> [Double] {
        guard let strikes = strikes else  {
            var tempSet = Set<Double>()
            tempSet.formUnion(calls.keys)
            tempSet.formUnion(putts.keys)
            let strikes = Array(tempSet).sorted()
            self.strikes = strikes
            return strikes
        }
        return strikes
    }

    /// Returns n strikes the are centered around a specified strike value.
    ///
    /// - Parameters:
    ///   - numberOfStrikes: the maximal number of strikes to return.
    ///   - strike: the center strike.
    /// - Throws: ``ArgumentException/illegalArgumentException`` when n < 0
    public func getNStrikesAround(numberOfStrikes: Int, strike: Double) throws -> [Double] {
        if numberOfStrikes < 0 {
            throw ArgumentException.illegalArgumentException
        }
        let strikes = getStrikes()
        var foundIndex = -strikes.count - 1
        for (index, element) in strikes.enumerated() {
            if element > strike {
                foundIndex = -index - 1
                break
            }
            if element == strike {
                foundIndex = index
                break
            }
        }

        if foundIndex < 0 {
            foundIndex = -foundIndex - 1
        }
        let fromTime = max(0, foundIndex - numberOfStrikes/2)
        let toTime = min(strikes.count, fromTime + numberOfStrikes)
        return Array(strikes[fromTime..<toTime])
    }

    public func addOption(isCall: Bool, strike: Double, option: T) {
        if isCall {
            calls[strike] = option
        } else {
            putts[strike] = option
        }
    }

    public func toString() -> String {
        return "expiration=\(DayUtil.getYearMonthDayByDayId(expiration))" +
        (lastTrade != 0 ? ", lastTrade=\(DayUtil.getYearMonthDayByDayId(lastTrade))" : "") +
        (multiplier != 0 ? ", multiplier=\(multiplier)" : "") +
        (spc != 0 ? ", spc=\(spc)" : "") +
        (additionalUnderlyings.length > 0 ? ", additionalUnderlyings=\(additionalUnderlyings)" : "") +
        (mmy.length > 0 ? ", mmy=\(mmy)" : "") +
        (optionType.length > 0 ? ", optionType=\(optionType)" : "") +
        (expirationStyle.length > 0 ? ", expirationStyle=\(expirationStyle)" : "") +
        (settlementStyle.length > 0 ? ", settlementStyle=\(settlementStyle)" : "") +
        ", cfi=\(cfi)"

    }

}

extension OptionSeries: Equatable {
    public static func == (lhs: OptionSeries<T>, rhs: OptionSeries<T>) -> Bool {
        return lhs === rhs ||
        (rhs.expiration == lhs.expiration &&
         rhs.lastTrade == lhs.lastTrade &&
         rhs.multiplier.isEqual(to: lhs.multiplier) &&
         rhs.spc.isEqual(to: lhs.spc) &&
         rhs.additionalUnderlyings == lhs.additionalUnderlyings &&
         rhs.expirationStyle == lhs.expirationStyle &&
         rhs.mmy == lhs.mmy &&
         rhs.optionType == lhs.optionType &&
         rhs.cfi == lhs.cfi &&
         rhs.settlementStyle == lhs.settlementStyle)
    }
    

}

extension OptionSeries: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(expiration)
        hasher.combine(lastTrade)
        let tempMultiplier = multiplier != +0.0 ? Double.doubleToLongBits(value: multiplier) : Long(0)
        hasher.combine( (tempMultiplier ^ (tempMultiplier >>> 32)))
        let tempSpc = spc != +0.0 ? Double.doubleToLongBits(value: spc) : Long(0)
        hasher.combine((tempSpc ^ (tempSpc >>> 32)))
        hasher.combine(additionalUnderlyings)
        hasher.combine(mmy)
        hasher.combine(optionType)
        hasher.combine(expirationStyle)
        hasher.combine(settlementStyle)
        hasher.combine(cfi)
    }
}

extension OptionSeries {
    func compare(_ rhs: OptionSeries) -> ComparisonResult {
        if expiration < rhs.expiration {
            return .orderedAscending
        }
        if expiration > rhs.expiration {
            return .orderedDescending
        }
        if lastTrade < rhs.lastTrade {
            return .orderedAscending
        }
        if lastTrade > rhs.lastTrade {
            return .orderedDescending
        }
        var result = multiplier.compare(rhs.multiplier)
        if result != .orderedSame {
            return result
        }
        result = spc.compare(rhs.spc)
        if result != .orderedSame {
            return result
        }
        result = additionalUnderlyings.compare(rhs.additionalUnderlyings)
        if result != .orderedSame {
            return result
        }
        result = mmy.compare(rhs.mmy)
        if result != .orderedSame {
            return result
        }
        result = optionType.compare(rhs.optionType)
        if result != .orderedSame {
            return result
        }
        result = expirationStyle.compare(rhs.expirationStyle)
        if result != .orderedSame {
            return result
        }
        result = settlementStyle.compare(rhs.settlementStyle)
        if result != .orderedSame {
            return result
        }
        return cfi.compare(rhs.cfi)
    }
}
