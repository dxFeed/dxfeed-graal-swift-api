//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation

///  Builder class for a set of option chains grouped by product or underlying symbol.
///
///  <T> The type of option instrument instances.
public class OptionChainsBuilder<T> {
    private var product = ""
    private var underlying = ""
    var series = OptionSeries<T>()
    var cfi = ""
    var strike = 0.0

    private var chains = [String: OptionChain<T>]()
    /// Changes product for futures and options on futures (underlying asset name).
    public func setProduct(_ value: String) {
        self.product = value.isEmpty ? "" : value
    }

    /// Changes primary underlying symbol for options.
    /// Example: "C", "/YGM9"
    public func setUnderlying(_ value: String) {
        self.underlying = value.isEmpty ? "" : value
    }

    /// Changes day id of expiration.
    public func setExpiration(_ value: Long) {
        series.expiration = value
    }

    /// Changes day id of last trading day.
    public func setLastTrade(_ value: Long) {
        series.lastTrade = value
    }

    /// Changes market value multiplier.
    public func setMultiplier(_ value: Double) {
        series.multiplier = value
    }

    /// Changes shares per contract for options.
    public func setSPC(_ value: Double) {
        series.spc = value
    }

    /// Changes additional underlyings for options, including additional cash.
    ///
    /// It shall use following format:
    ///     <VALUE> ::= <empty> | <LIST>
    ///     <LIST> ::= <AU> | <AU> <semicolon> <space> <LIST>
    ///     <AU> ::= <UNDERLYING> <space> <SPC>
    /// the list shall be sorted by <UNDERLYING>.
    /// Example: "SE 50", "FIS 53; US$ 45.46".
    public func setAdditionalUnderlyings(_ value: String) {
        series.additionalUnderlyings = value.isEmpty ? "" : value
    }

    /// Changes maturity month-year as provided for corresponding FIX tag (200).
    ///
    /// It can use several different formats depending on data source:
    ///
    /// YYYYMM – if only year and month are specified
    /// YYYYMMDD – if full date is specified
    /// YYYYMMwN – if week number (within a month) is specified
    public func setMMY(_ value: String) {
        series.mmy = value.isEmpty ? "" : value
    }

    /// Changes type of option.
    ///
    /// It shall use one of following values:
    /// STAN = Standard Options
    /// LEAP = Long-term Equity AnticiPation Securities
    /// SDO = Special Dated Options
    /// BINY = Binary Options
    /// FLEX = FLexible EXchange Options
    /// VSO = Variable Start Options
    /// RNGE = Range
    public func setOptionType(_ value: String) {
        series.optionType = value.isEmpty ? "" : value
    }

    /// Returns expiration cycle style, such as "Weeklys", "Quarterlys".
    public func setExpirationStyle(_ value: String) {
        series.expirationStyle = value.isEmpty ? "" : value
    }

    /// Changes settlement price determination style, such as "Open", "Close".
    public func setSettlementStyle(_ value: String) {
        series.settlementStyle = value.isEmpty ? "" : value
    }

    /// Changes Classification of Financial Instruments code.
    /// It is a mandatory field as it is the only way to distinguish Call/Put option type,
    /// American/European exercise, Cash/Physical delivery.
    /// It shall use six-letter CFI code from ISO 10962 standard.
    /// It is allowed to use 'X' extensively and to omit trailing letters (assumed to be 'X').
    /// See [ISO 10962 on Wikipedia](http://en.wikipedia.org/wiki/ISO_10962)
    public func setCFI(_ value: String) {
        self.cfi = value.isEmpty ? "" : value
        series.cfi = self.cfi.length < 2 ? self.cfi : (self.cfi[0] + "X" + self.cfi.substring(fromIndex: 2))
    }

    /// Changes strike price for options.
    public func setStrike(_ value: Double) {
        self.strike = value
    }

    /// Adds an option instrument to this builder.
    ///
    /// Option is added to chains for the ntly set ``setProduct(_:)`` and/or
    /// ``setUnderlying(_:)`` to the ``OptionSeries`` that corresponding
    /// to all other currently set attributes. This method is safe in the sense that is ignores
    /// illegal state of the builder. It only adds an option when all of the following conditions are met:
    ///
    ///  ``setCFI(_:)`` is set and starts with either "OC" for call or "OP" for put.
    ///  ``setExpiration(_:)`` is set and is not zero;
    ///  ``setStrike(_:)`` is set and is not  Double.isNan nor Double.isInfinite;
    ///  ``setProduct(_:)`` or ``setUnderlying(_:)`` are set;
    ///
    /// All the attributes remain set as before after the call to this method, but
    /// ``getChains()`` are updated correspondingly.
    public func addOption(_ option: T) {
        let isCall = cfi.hasPrefix("OC")
        if !isCall && !cfi.hasPrefix("OP") {
            return
        }
        if series.expiration == 0 {
            return
        }
        if strike.isNaN || strike.isInfinite {
            return
        }
        if product.length > 0 {
            getOrCreateChain(symbol: product)
                .addOption(series: series, isCall: isCall, strike: strike, option: option)
        }
        if underlying.length > 0 {
            getOrCreateChain(symbol: underlying)
                .addOption(series: series, isCall: isCall, strike: strike, option: option)
        }
    }

    private func getOrCreateChain(symbol: String) -> OptionChain<T> {
        guard let chain = chains[symbol] else {
            let chain = OptionChain<T>(symbol: symbol)
            chains[symbol] = chain
            return chain
        }
        return chain
    }

    /// Returns a view of chains created by this builder.
    public func getChains() -> [String: OptionChain<T>] {
        return chains
    }
}

public extension OptionChainsBuilder where T == InstrumentProfile {

    /// Builds options chains for all options from the given collections of ``InstrumentProfile``.
    ///
    /// - Parameters:
    ///   - profiles: collection of instrument profiles..
    ///   - Returns: builder with all the options from instruments collection.
    static func build(_ profiles: [InstrumentProfile]) -> OptionChainsBuilder {
        let ocb = OptionChainsBuilder<InstrumentProfile>()
        for profile in profiles where profile.getIpfType() == .option {
            ocb.setProduct(profile.product)
            ocb.setUnderlying(profile.underlying)
            ocb.setExpiration(Long(profile.expiration))
            ocb.setLastTrade(Long(profile.lastTrade))
            ocb.setMultiplier(profile.multiplier)
            ocb.setSPC(profile.spc)
            ocb.setAdditionalUnderlyings(profile.additionalUnderlyings)
            ocb.setMMY(profile.mmy)
            ocb.setOptionType(profile.optionType)
            ocb.setExpirationStyle(profile.expirationStyle)
            ocb.setSettlementStyle(profile.settlementStyle)
            ocb.setCFI(profile.cfi)
            ocb.setStrike(profile.strike)
            ocb.addOption(profile)
        }

        return ocb
    }

}
