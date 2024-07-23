//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
/// Represents basic profile information about market instrument.
///
/// [For more details see](http://www.dxfeed.com/downloads/documentation/dxFeed_Instrument_Profile_Format.pdf)
public class InstrumentProfile {
    let native: NativeInstrumentProfile

    init() throws {
        self.native = try NativeInstrumentProfile()
    }

    init(_ native: NativeInstrumentProfile) {
        self.native = native
    }

    func toString() -> String {
        return native.toString()
    }
}

extension InstrumentProfile {
    /// Type of instrument.
    ///
    /// It takes precedence in conflict cases with other fields.
    /// It is a mandatory field. It may not be empty.
    /// Example: "STOCK", "FUTURE", "OPTION".
    public var type: String {
        get {
            return native.type
        }
        set {
            native.type = newValue
        }
    }
    /// Identifier of instrument,
    public var symbol: String {
        get {
            return native.symbol
        }
        set {
            native.symbol = newValue
        }
    }
    /// description of instrument
    public var descriptionStr: String {
        get {
            return native.descriptionString
        }
        set {
            native.descriptionString = newValue
        }
    }
    /// Identifier of instrument in national language.
    public var localSymbol: String {
        get {
            return native.localSymbol
        }
        set {
            native.localSymbol = newValue
        }
    }
    /// Description of instrument in national language.
    public var localDescription: String {
        get {
            return native.localDescription
        }
        set {
            native.localDescription = newValue
        }
    }
    /// Country of origin (incorporation) of corresponding company or parent entity.
    ///
    /// It shall use two-letter country code from ISO 3166-1 standard.
    /// [ISO 3166-1 on Wikipedia](http://en.wikipedia.org/wiki/ISO_3166-1)
    public var country: String {
        get {
            return native.country
        }
        set {
            native.country = newValue
        }
    }
    /// Official Place Of Listing, the organization that have listed this instrument.
    ///
    /// Instruments with multiple listings shall use separate profiles for each listing.
    /// It shall use Market Identifier Code (MIC) from ISO 10383 standard.
    /// [ISO 10383 on Wikipedia](http://en.wikipedia.org/wiki/ISO_10383)
    /// or [MIC homepage](http://www.iso15022.org/MIC/homepageMIC.htm)
    /// Example: "XNAS", "RTSX"/
    public var opol: String {
        get {
            return native.oPOL
        }
        set {
            native.oPOL = newValue
        }
    }
    public var exchangeData: String {
        get {
            return native.exchangeData
        }
        set {
            native.exchangeData = newValue
        }
    }
    /// Exchange-specific data required to properly identify instrument when communicating with exchange.
    public var exchanges: String {
        get {
            return native.exchanges
        }
        set {
            native.exchanges = newValue
        }
    }
    /// Currency of quotation, pricing and trading.
    ///
    /// It shall use three-letter currency code from ISO 4217 standard.
    ///
    /// [ISO 4217 on Wikipedia](http://en.wikipedia.org/wiki/ISO_4217)
    ///
    /// Example: "USD", "RUB".
    public var currency: String {
        get {
            return native.currency
        }
        set {
            native.currency = newValue
        }
    }
    /// Base currency of currency pair (FOREX instruments).
    /// It shall use three-letter currency code
    public var baseCurrency: String {
        get {
            return native.baseCurrency
        }
        set {
            native.baseCurrency = newValue
        }
    }
    /// Classification of Financial Instruments code.
    ///
    /// It is a mandatory field for OPTION instruments as it is the only way to distinguish Call/Put type,
    /// American/European exercise, Cash/Physical delivery.
    /// It shall use six-letter CFI code from ISO 10962 standard.
    /// It is allowed to use 'X' extensively and to omit trailing letters (assumed to be 'X').
    ///
    /// [ISO 10962 on Wikipedia](http://en.wikipedia.org/wiki/ISO_10962)
    ///
    /// Example: "ESNTPB", "ESXXXX", "ES" , "OPASPS".
    public var cfi: String {
        get {
            return native.cFI
        }
        set {
            native.cFI = newValue
        }
    }
    /// International Securities Identifying Number.
    ///
    /// It shall use twelve-letter code from ISO 6166 standard.
    ///
    /// [ISO 6166 on Wikipedia](http://en.wikipedia.org/wiki/ISO_6166) and
    /// [ISIN on Wikipedia](http://en.wikipedia.org/wiki/International_Securities_Identifying_Number)
    ///
    /// Example: "DE0007100000", "US38259P5089".
    public var isin: String {
        get {
            return native.iSIN
        }
        set {
            native.iSIN = newValue
        }
    }
    /// Stock Exchange Daily Official List.
    ///
    /// It shall use seven-letter code assigned by London Stock Exchange.
    ///
    /// [SEDOL on Wikipedia](http://en.wikipedia.org/wiki/SEDOL)
    /// [SEDOL on LSE](http://www.londonstockexchange.com/en-gb/products/informationproducts/sedol/)
    ///
    /// Example: "2310967", "5766857".
    public var sedol: String {
        get {
            return native.sEDOL
        }
        set {
            native.sEDOL = newValue
        }
    }
    /// Committee on Uniform Security Identification Procedures code.
    ///
    /// It shall use nine-letter code assigned by CUSIP Services Bureau.
    ///
    /// [CUSIP on Wikipedia](http://en.wikipedia.org/wiki/CUSIP)
    ///
    /// Example: "38259P508".
    public var cusip: String {
        get {
            return native.cUSIP
        }
        set {
            native.cUSIP = newValue
        }
    }
    /// Industry Classification Benchmark.
    ///
    /// It shall use four-digit number from ICB catalog.
    ///
    /// [ICB on Wikipedia](http://en.wikipedia.org/wiki/Industry_Classification_Benchmark)
    /// or [ICB homepage](http://www.icbenchmark.com/)
    ///
    /// Example: "9535".
    public var icb: Int32 {
        get {
            return native.iCB
        }
        set {
            native.iCB = newValue
        }
    }
    /// Standard Industrial Classification.
    ///
    /// It shall use four-digit number from SIC catalog.
    ///
    /// [SIC on Wikipedia](http://en.wikipedia.org/wiki/Standard_Industrial_Classification)
    /// or  [SIC structure](https://www.osha.gov/pls/imis/sic_manual.html)
    ///
    /// Example: "7371".
    public var sic: Int32 {
        get {
            return native.sIC
        }
        set {
            native.sIC = newValue
        }
    }
    /// Market value multiplier.
    ///
    /// Example: 100, 33.2.
    public var multiplier: Double {
        get {
            return native.multiplier
        }
        set {
            native.multiplier = newValue
        }
    }
    /// Product for futures and options on futures (underlying asset name).
    ///
    /// Example: "/YG".
    public var product: String {
        get {
            return native.product
        }
        set {
            native.product = newValue
        }
    }
    /// Primary underlying symbol for options.
    ///
    /// Example: "C", "/YGM9"
    public var underlying: String {
        get {
            return native.underlying
        }
        set {
            native.underlying = newValue
        }
    }
    /// Shares per contract for options.
    ///
    /// Example: 1, 100.
    public var spc: Double {
        get {
            return native.sPC
        }
        set {
            native.sPC = newValue
        }
    }
    /// Additional underlyings for options, including additional cash.
    ///
    /// It shall use following format:
    ///
    ///     <VALUE> ::= <empty> | <LIST>
    ///     <LIST> ::= <AU> | <AU> <semicolon> <space> <LIST>
    ///     <AU> ::= <UNDERLYING> <space> <SPC>
    /// the list shall be sorted by <UNDERLYING>.
    ///
    /// Example: "SE 50", "FIS 53; US$ 45.46".
    public var additionalUnderlyings: String {
        get {
            return native.additionalUnderlyings
        }
        set {
            native.additionalUnderlyings = newValue
        }
    }
    /// Maturity month-year as provided for corresponding FIX tag (200).
    ///
    /// It can use several different formats depending on data source:
    ///
    /// YYYYMM – if only year and month are specified
    /// YYYYMMDD – if full date is specified
    /// YYYYMMwN – if week number (within a month) is specified
    public var mmy: String {
        get {
            return native.mMY
        }
        set {
            native.mMY = newValue
        }
    }
    /// Day id of expiration.
    public var expiration: Int32 {
        get {
            return native.expiration
        }
        set {
            native.expiration = newValue
        }
    }
    /// Day id of last trading day.
    public var lastTrade: Int32 {
        get {
            return native.lastTrade
        }
        set {
            native.lastTrade = newValue
        }
    }
    /// Strike price for options.
    public var strike: Double {
        get {
            return native.strike
        }
        set {
            native.strike = newValue
        }
    }
    /// Type of option.
    ///
    /// It shall use one of following values:
    ///
    /// STAN = Standard Options
    ///
    /// LEAP = Long-term Equity AnticiPation Securities
    ///
    /// SDO = Special Dated Options
    ///
    /// BINY = Binary Options
    ///
    /// FLEX = FLexible EXchange Options
    ///
    /// VSO = Variable Start Options
    ///
    /// RNGE = Range
    public var optionType: String {
        get {
            return native.optionType
        }
        set {
            native.optionType = newValue
        }
    }
    /// Expiration cycle style, such as "Weeklys", "Quarterlys".
    public var expirationStyle: String {
        get {
            return native.expirationStyle
        }
        set {
            native.expirationStyle = newValue
        }
    }
    /// Settlement price determination style, such as "Open", "Close".
    public var settlementStyle: String {
        get {
            return native.settlementStyle
        }
        set {
            native.settlementStyle = newValue
        }
    }
    /// Minimum allowed price increments with corresponding price /// It shall use following format:
    ///
    ///     <VALUE> ::= <empty> | <LIST>
    ///     <LIST> ::= <INCREMENT> | <RANGE> <semicolon> <space> <LIST>
    ///     <RANGE> ::= <INCREMENT> <space> <UPPER_LIMIT>
    /// the list shall be sorted by <UPPER_LIMIT>.
    ///
    /// Example: "0.25", "0.01 3; 0.05".
    public var priceIncrements: String {
        get {
            return native.priceIncrements
        }
        set {
            native.priceIncrements = newValue
        }
    }
    /// Trading hours specification.
    public var tradingHours: String {
        get {
            return native.tradingHours
        }
        set {
            native.tradingHours = newValue
        }
    }
}
extension InstrumentProfile {
    /// Returns field value with a specified name.
    public func getField(_ name: String) -> String {
        return native.getField(name)
    }
    /// Changes field value with a specified name.
    public func setField(_ name: String, _ value: String) {
        return native.setField(name, value)
    }
    /// Returns numeric field value with a specified name.
    public func getNumericField(_ name: String) -> Double {
        return native.getNumericField(name)

    }
    /// Changes numeric field value with a specified name.
    public func setNumericField(_ name: String, _ value: Double) {
        return native.setNumericField(name, value)
    }
    /// Returns day id value for a date field with a specified name.
    public func getDateField(_ name: String) -> Int32 {
        return native.getDateField(name)
    }
    /// Changes day id value for a date field with a specified name.
    public func setDateField(_ name: String, _ value: Int32) {
        return native.setDateField(name, value)
    }
    /// Adds names of non-empty custom fields to specified collection.
    ///
    /// The collection to which the names of non-empty custom fields will be added.
    /// - Returns: true if changed, otherwise false
    public func addNonEmptyCustomFieldNames(_ targetFieldNames: inout [String]) -> Bool {
        return native.addNonEmptyCustomFieldNames(&targetFieldNames)
    }
}

extension InstrumentProfile: Hashable {
    public static func == (lhs: InstrumentProfile, rhs: InstrumentProfile) -> Bool {
        if lhs === rhs {
            return true
        } else {
            return lhs.native == rhs.native
        }
    }

    public func hash(into hasher: inout Hasher) {
        native.hash(into: &hasher)
    }
}
