//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation

public class OptionSeries<T> {

    /// Day id of expiration.
    public let expiration: Long
    /// Day id of last trading day.
    public let lastTrade: Long
    /// Market value multiplier.
    public let multiplier: Double
    /// Shares per contract for options.
    public let spc: Double
    /// Additional underlyings for options, including additional cash.
    ///
    /// It shall use following format:
    ///     <VALUE> ::= <empty> | <LIST>
    ///     <LIST> ::= <AU> | <AU> <semicolon> <space> <LIST>
    ///     <AU> ::= <UNDERLYING> <space> <SPC>
    /// the list shall be sorted by <UNDERLYING>.
    /// Example: "SE 50", "FIS 53; US$ 45.46".
    public let additionalUnderlyings: String
    /// Maturity month-year as provided for corresponding FIX tag (200).
    ///
    /// It can use several different formats depending on data source:
    ///
    /// YYYYMM – if only year and month are specified
    /// YYYYMMDD – if full date is specified
    /// YYYYMMwN – if week number (within a month) is specified
    public let mmy: String
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
    public let optionType: String
    /// Expiration cycle style, such as "Weeklys", "Quarterlys".
    public let expirationStyle: String
    /// Settlement price determination style, such as "Open", "Close".
    public let settlementStyle: String
    /// Classification of Financial Instruments code of this option series.
    /// It shall use six-letter CFI code from ISO 10962 standard.
    /// It is allowed to use 'X' extensively and to omit trailing letters (assumed to be 'X').
    /// See [ISO 10962 on Wikipedia](http://en.wikipedia.org/wiki/ISO_10962)
    /// It starts with "OX" as both ``calls`` and ``putts`` are stored in a series.
    public let cfi: String
    /// Dict of all calls from strike to a corresponding option instrument.
    public private(set) var  calls = [Double: T]()
    /// Dict of all puts from strike to a corresponding option instrument.
    public private(set) var putts = [Double: T]()
    
    private var strikes: [Double]? = nil

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

    private init(other: OptionSeries) {
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
                continue
            }
            if element == strike {
                foundIndex = index
                continue
            }
        }

        if foundIndex < 0 {
            foundIndex = -foundIndex - 1
        }
        let from = max(0, foundIndex - numberOfStrikes/2)
        let to = min(strikes.count, from + numberOfStrikes)
        return Array(strikes[from..<to])
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
        (settlementStyle.length > 0 ? ", settlementStyle=\(settlementStyle)" : "")
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
