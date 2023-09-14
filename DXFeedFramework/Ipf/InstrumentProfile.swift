//
//  InstrumentProfile.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 29.08.23.
//

import Foundation
/// Represents basic profile information about market instrument.
///
/// [For more details see](http://www.dxfeed.com/downloads/documentation/dxFeed_Instrument_Profile_Format.pdf)
public class InstrumentProfile {
    /// Type of instrument.
    ///
    /// It takes precedence in conflict cases with other fields.
    /// It is a mandatory field. It may not be empty.
    /// Example: "STOCK", "FUTURE", "OPTION".
    var type = "" {
        didSet {
            do {
                if type != "" {
                    ipfType = try InstrumentProfileType.find(type)
                }
            } catch ArgumentException.unknowValue(let value, let supportedValues) {
                print("InstrumentProfile: not found \(value) in \(supportedValues ?? "")")
            } catch {
                print("InstrumentProfile: set type \(error)")
            }
        }
    }
    /// Identifier of instrument,
    public var symbol = ""
    /// description of instrument
    public var descriptionStr = ""
    /// Identifier of instrument in national language.
    public var localSymbol = ""
    /// Description of instrument in national language.
    public var localDescription = ""
    /// Country of origin (incorporation) of corresponding company or parent entity.
    ///
    /// It shall use two-letter country code from ISO 3166-1 standard.
    /// [ISO 3166-1 on Wikipedia](http://en.wikipedia.org/wiki/ISO_3166-1)
    public var country = ""
    /// Official Place Of Listing, the organization that have listed this instrument.
    ///
    /// Instruments with multiple listings shall use separate profiles for each listing.
    /// It shall use Market Identifier Code (MIC) from ISO 10383 standard.
    /// [ISO 10383 on Wikipedia](http://en.wikipedia.org/wiki/ISO_10383)
    /// or [MIC homepage](http://www.iso15022.org/MIC/homepageMIC.htm)
    /// Example: "XNAS", "RTSX"/
    public var opol = ""
    public var exchangeData = ""
    /// Exchange-specific data required to properly identify instrument when communicating with exchange.
    public var exchanges = ""
    /// Currency of quotation, pricing and trading.
    ///
    /// It shall use three-letter currency code from ISO 4217 standard.
    ///
    /// [ISO 4217 on Wikipedia](http://en.wikipedia.org/wiki/ISO_4217)
    ///
    /// Example: "USD", "RUB".
    public var currency = ""
    /// Base currency of currency pair (FOREX instruments).
    /// It shall use three-letter currency code
    public var baseCurrency = ""
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
    public var cfi = ""
    /// International Securities Identifying Number.
    ///
    /// It shall use twelve-letter code from ISO 6166 standard.
    ///
    /// [ISO 6166 on Wikipedia](http://en.wikipedia.org/wiki/ISO_6166) and
    /// [ISIN on Wikipedia](http://en.wikipedia.org/wiki/International_Securities_Identifying_Number)
    ///
    /// Example: "DE0007100000", "US38259P5089".
    public var isin = ""
    /// Stock Exchange Daily Official List.
    ///
    /// It shall use seven-letter code assigned by London Stock Exchange.
    ///
    /// [SEDOL on Wikipedia](http://en.wikipedia.org/wiki/SEDOL)
    /// [SEDOL on LSE](http://www.londonstockexchange.com/en-gb/products/informationproducts/sedol/)
    ///
    /// Example: "2310967", "5766857".
    public var sedol = ""
    /// Committee on Uniform Security Identification Procedures code.
    ///
    /// It shall use nine-letter code assigned by CUSIP Services Bureau.
    ///
    /// [CUSIP on Wikipedia](http://en.wikipedia.org/wiki/CUSIP)
    ///
    /// Example: "38259P508".
    public var cusip = ""
    /// Industry Classification Benchmark.
    ///
    /// It shall use four-digit number from ICB catalog.
    ///
    /// [ICB on Wikipedia](http://en.wikipedia.org/wiki/Industry_Classification_Benchmark)
    /// or [ICB homepage](http://www.icbenchmark.com/)
    ///
    /// Example: "9535".
    public var icb: Int32 = 0
    /// Standard Industrial Classification.
    ///
    /// It shall use four-digit number from SIC catalog.
    ///
    /// [SIC on Wikipedia](http://en.wikipedia.org/wiki/Standard_Industrial_Classification)
    /// or  [SIC structure](https://www.osha.gov/pls/imis/sic_manual.html)
    ///
    /// Example: "7371".
    public var sic: Int32 = 0
    /// Market value multiplier.
    ///
    /// Example: 100, 33.2.
    public var multiplier: Double = 0
    /// Product for futures and options on futures (underlying asset name).
    ///
    /// Example: "/YG".
    public var product = ""
    /// Primary underlying symbol for options.
    ///
    /// Example: "C", "/YGM9"
    public var underlying = ""
    /// Shares per contract for options.
    ///
    /// Example: 1, 100.
    public var spc: Double = 0
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
    public var additionalUnderlyings = ""
    /// Maturity month-year as provided for corresponding FIX tag (200).
    ///
    /// It can use several different formats depending on data source:
    ///
    /// YYYYMM – if only year and month are specified
    /// YYYYMMDD – if full date is specified
    /// YYYYMMwN – if week number (within a month) is specified
    public var mmy = ""
    /// Day id of expiration.
    public var expiration: Int32 = 0
    /// Day id of last trading day.
    public var lastTrade: Int32 = 0
    /// Strike price for options.
    public var strike: Double = 0
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
    public var optionType = ""
    /// Expiration cycle style, such as "Weeklys", "Quarterlys".
    public var expirationStyle = ""
    /// Settlement price determination style, such as "Open", "Close".
    public var settlementStyle = ""
    /// Minimum allowed price increments with corresponding price /// It shall use following format:
    ///
    ///     <VALUE> ::= <empty> | <LIST>
    ///     <LIST> ::= <INCREMENT> | <RANGE> <semicolon> <space> <LIST>
    ///     <RANGE> ::= <INCREMENT> <space> <UPPER_LIMIT>
    /// the list shall be sorted by <UPPER_LIMIT>.
    ///
    /// Example: "0.25", "0.01 3; 0.05".
    public var priceIncrements = ""
    /// Trading hours specification.
    public var tradingHours = ""

    var customFields = [String: String]()

    public var ipfType: InstrumentProfileType?

    /// Creates an instrument profile with default values.
    public init() {
        // to activaate didSet methods
        updateValues()
    }
    private func updateValues() {
        type = ""
    }
}

extension InstrumentProfile {
    func getCustomFieldsList() -> [String] {
        var result = [String]()
        customFields.forEach { key, value in
            result.append(key)
            result.append(value)
        }
        return result
    }
    /// Returns field value with a specified name.
    public func getField(_ name: String) -> String {
        if let ipfField = InstrumentProfileField.find(name) {
            return ipfField.getField(instrumentProfile: self)
        }
        return customFields[name] ?? ""
    }
    /// Changes field value with a specified name.
    public func setField(_ name: String, _ value: String) {
        if let ipfField = InstrumentProfileField.find(name) {
            ipfField.setField(instrumentProfile: self, value: value)
        } else {
            customFields[name] = value
        }
    }
    /// Returns numeric field value with a specified name.
    public func getNumericField(_ name: String) -> Double {
        if let ipfField = InstrumentProfileField.find(name) {
            if let value = try? ipfField.getNumericField(instrumentProfile: self) {
                return value
            }
        }
        let value = customFields[name]
        guard let value = value else {
            return 0
        }
        if value.isEmpty {
            return 0
        }
        if value.length == 10 &&
            value[4] == "-" &&
            value[7] == "-" {
            return Double(InstrumentProfileField.parseDate(value))
        } else {
            return InstrumentProfileField.parseNumber(value)
        }
    }
    /// Changes numeric field value with a specified name.
    public func setNumericField(_ name: String, _ value: Double) {
        if let ipfField = InstrumentProfileField.find(name) {
            try? ipfField.setNumericField(instrumentProfile: self, value: value)
        } else {
            setField(name, InstrumentProfileField.formatNumber(value))
        }
    }
    /// Returns day id value for a date field with a specified name.
    public func getDateField(_ name: String) -> Long {
        if let ipfField = InstrumentProfileField.find(name) {
            if let value = try? ipfField.getNumericField(instrumentProfile: self) {
                return Long(value)
            }
        }
        let value = customFields[name]
        guard let value = value else {
            return 0
        }
        if value.isEmpty {
            return 0
        }
        return InstrumentProfileField.parseDate(value)
    }
    /// Changes day id value for a date field with a specified name.
    public func setDateField(_ name: String, _ value: Long) {
        if let ipfField = InstrumentProfileField.find(name) {
            try? ipfField.setNumericField(instrumentProfile: self, value: Double(value))
        } else {
            setField(name, InstrumentProfileField.formatDate(value))
        }
    }
    /// Adds names of non-empty custom fields to specified collection.
    public func addNonEmptyCustomFieldNames(_ targetFieldNames: inout [String]) -> Bool {
        var updated = false
        customFields.forEach { key, value in
            if !value.isEmpty {
                targetFieldNames.append(key)
                updated = true
            }
        }
        return updated
    }
}

extension InstrumentProfile: Hashable {
    public static func == (lhs: InstrumentProfile, rhs: InstrumentProfile) -> Bool {
        if lhs === rhs {
            return true
        } else {
            return lhs.type == rhs.type &&
            lhs.symbol == rhs.symbol &&
            lhs.descriptionStr == rhs.descriptionStr &&
            lhs.localSymbol == rhs.localSymbol &&
            lhs.localDescription == rhs.localDescription &&
            lhs.country == rhs.country &&
            lhs.opol == rhs.opol &&
            lhs.exchangeData == rhs.exchangeData &&
            lhs.exchanges == rhs.exchanges &&
            lhs.currency == rhs.currency &&
            lhs.baseCurrency == rhs.baseCurrency &&
            lhs.cfi == rhs.cfi &&
            lhs.isin == rhs.isin &&
            lhs.sedol == rhs.sedol &&
            lhs.cusip == rhs.cusip &&
            lhs.icb == rhs.icb &&
            lhs.sic == rhs.sic &&
            (lhs.multiplier ~== rhs.multiplier) &&
            lhs.product == rhs.product &&
            lhs.underlying == rhs.underlying &&
            (lhs.spc ~== rhs.spc) &&
            lhs.additionalUnderlyings == rhs.additionalUnderlyings &&
            lhs.mmy == rhs.mmy &&
            lhs.expiration == rhs.expiration &&
            lhs.lastTrade == rhs.lastTrade &&
            (lhs.strike ~== rhs.strike) &&
            lhs.optionType == rhs.optionType &&
            lhs.expirationStyle == rhs.expirationStyle &&
            lhs.settlementStyle == rhs.settlementStyle &&
            lhs.priceIncrements == rhs.priceIncrements &&
            lhs.tradingHours == rhs.tradingHours &&
            lhs.customFields == rhs.customFields
        }
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(symbol)
        hasher.combine(descriptionStr)
        hasher.combine(localSymbol)
        hasher.combine(localDescription)
        hasher.combine(country)
        hasher.combine(opol)
        hasher.combine(exchangeData)
        hasher.combine(exchanges)
        hasher.combine(currency)
        hasher.combine(baseCurrency)
        hasher.combine(cfi)
        hasher.combine(isin)
        hasher.combine(sedol)
        hasher.combine(cusip)
        hasher.combine(icb)
        hasher.combine(sic)
        hasher.combine(multiplier)
        hasher.combine(product)
        hasher.combine(underlying)
        hasher.combine(spc)
        hasher.combine(additionalUnderlyings)
        hasher.combine(mmy)
        hasher.combine(expiration)
        hasher.combine(lastTrade)
        hasher.combine(strike)
        hasher.combine(optionType)
        hasher.combine(expirationStyle)
        hasher.combine(settlementStyle)
        hasher.combine(priceIncrements)
        hasher.combine(tradingHours)
        hasher.combine(customFields)
    }
}
