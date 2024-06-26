//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation

/// Set of option series for a single product or underlying symbol.
/// 
///  <T> The type of option instrument instances.
public class OptionChain<T> {
    /// Symbol (product or underlying) of this option chain.
    public let symbol: String

    var seriesMap = [OptionSeries<T>: OptionSeries<T>]()

    init(symbol: String) {
        self.symbol = symbol
    }

    /// Returns a shall copy of this option chain.
    /// 
    /// - Returns: a shall copy of this option chain.
    public func clone() -> OptionChain<T> {
        let clone = OptionChain(symbol: symbol)
        seriesMap.forEach { _, value in
            let clonedSeries = value.clone()
            clone.seriesMap[clonedSeries] = clonedSeries
        }
        return clone
    }

    /// Returns a sorted list of option series of this option chain.
    public func getSeries() -> [OptionSeries<T>] {
        return Set(seriesMap.keys).sorted { lhs, rhs in
            let compareResult = lhs.compare(rhs)
            return compareResult == .orderedAscending
        }
    }

    func addOption(series: OptionSeries<T>, isCall: Bool, strike: Double, option: T) {
        var oSeries = seriesMap[series]
        if oSeries == nil {
            let tempOs = OptionSeries(other: series)
            seriesMap[tempOs] = tempOs
            oSeries = tempOs
        }
        oSeries?.addOption(isCall: isCall, strike: strike, option: option)
    }
}
