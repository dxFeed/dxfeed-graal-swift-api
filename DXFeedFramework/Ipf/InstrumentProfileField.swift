//
//  InstrumentProfileField.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 29.08.23.
//

import Foundation

public enum InstrumentProfileField: String, CaseIterable {
    case type  = "TYPE"
    case symbol = "SYMBOL"
    case descriptionStr = "DESCRIPTION"
    case localSymbol = "LOCAL_SYMBOL"
    case localDescription = "LOCAL_DESCRIPTION"
    case country = "COUNTRY"
    case opol = "OPOL"
    case exchangeData = "EXCHANGE_DATA"
    case exchanges = "EXCHANGES"
    case currency = "CURRENCY"
    case baseCurrency = "BASE_CURRENCY"
    case cfi = "CFI"
    case isin = "ISIN"
    case sedol = "SEDOL"
    case cusip = "CUSIP"
    case icb = "ICB"
    case sic = "SIC"
    case multiplier = "MULTIPLIER"
    case product = "PRODUCT"
    case underlying = "UNDERLYING"
    case spc = "SPC"
    case additionalUnderlyings = "ADDITIONAL_UNDERLYINGS"
    case mmy = "MMY"
    case expiration = "EXPIRATION"
    case lastTrade = "LAST_TRADE"
    case strike = "STRIKE"
    case optionType = "OPTION_TYPE"
    case expirationStyle = "EXPIRATION_STYLE"
    case settlementStyle = "SETTLEMENT_STYLE"
    case priceIncrements = "PRICE_INCREMENTS"
    case tradingHours = "TRADING_HOURS"

    static let numericFields: Set<InstrumentProfileField> =
    [.icb, .sic, .multiplier, .spc, .expiration, .lastTrade, .strike]

    private struct Entry {
        let text: String
        let binary: Long

        init(text: String, binary: Long) {
            self.text = text
            self.binary = binary
        }
    }

    private static let parsedNumbers = ConcurrentDict<String, Entry>()
    private static let parsedDates = ConcurrentDict<String, Entry>()

    private static let formatedNumbers = ConcurrentDict<String, Entry>()
    private static let formatedDates = ConcurrentDict<String, Entry>()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 20
        formatter.usesGroupingSeparator = false
        return formatter
    }()

    static let map: [String: InstrumentProfileField] = {
        return Dictionary(uniqueKeysWithValues: InstrumentProfileField.allCases.map { ($0.rawValue, $0) })
    }()

    public static func find(_ name: String) -> InstrumentProfileField? {
        return map[name]
    }

    // swiftlint:disable function_body_length
    public func getField(instrumentProfile: InstrumentProfile) -> String {
        switch self {
        case .type:
            return instrumentProfile.type
        case .symbol:
            return instrumentProfile.symbol
        case .descriptionStr:
            return instrumentProfile.descriptionStr
        case .localSymbol:
            return instrumentProfile.localSymbol
        case .localDescription:
            return instrumentProfile.localDescription
        case .country:
            return instrumentProfile.country
        case .opol:
            return instrumentProfile.opol
        case .exchangeData:
            return instrumentProfile.exchangeData
        case .exchanges:
            return instrumentProfile.exchanges
        case .currency:
            return instrumentProfile.currency
        case .baseCurrency:
            return instrumentProfile.baseCurrency
        case .cfi:
            return instrumentProfile.cfi
        case .isin:
            return instrumentProfile.isin
        case .sedol:
            return instrumentProfile.sedol
        case .cusip:
            return instrumentProfile.cusip
        case .icb:
            return InstrumentProfileField.formatNumber(Double(instrumentProfile.icb))
        case .sic:
            return InstrumentProfileField.formatNumber(Double(instrumentProfile.sic))
        case .multiplier:
            return InstrumentProfileField.formatNumber(Double(instrumentProfile.multiplier))
        case .product:
            return instrumentProfile.product
        case .underlying:
            return instrumentProfile.underlying
        case .spc:
            return InstrumentProfileField.formatNumber(Double(instrumentProfile.spc))
        case .additionalUnderlyings:
            return instrumentProfile.additionalUnderlyings
        case .mmy:
            return instrumentProfile.mmy
        case .expiration:
            return InstrumentProfileField.formatNumber(Double(instrumentProfile.expiration))
        case .lastTrade:
            return InstrumentProfileField.formatNumber(Double(instrumentProfile.lastTrade))
        case .strike:
            return InstrumentProfileField.formatNumber(Double(instrumentProfile.strike))
        case .optionType:
            return instrumentProfile.optionType
        case .expirationStyle:
            return instrumentProfile.expirationStyle
        case .settlementStyle:
            return instrumentProfile.settlementStyle
        case .priceIncrements:
            return instrumentProfile.priceIncrements
        case .tradingHours:
            return instrumentProfile.tradingHours
        }
    }

    public func setField(instrumentProfile: InstrumentProfile, value: String) {
        switch self {
        case .type:
            instrumentProfile.type = value
        case .symbol:
            instrumentProfile.symbol = value
        case .descriptionStr:
            instrumentProfile.descriptionStr = value
        case .localSymbol:
            instrumentProfile.localSymbol = value
        case .localDescription:
            instrumentProfile.localDescription = value
        case .country:
            instrumentProfile.country = value
        case .opol:
            instrumentProfile.opol = value
        case .exchangeData:
            instrumentProfile.exchangeData = value
        case .exchanges:
            instrumentProfile.exchanges = value
        case .currency:
            instrumentProfile.currency = value
        case .baseCurrency:
            instrumentProfile.baseCurrency = value
        case .cfi:
            instrumentProfile.cfi = value
        case .isin:
            instrumentProfile.isin = value
        case .sedol:
            instrumentProfile.sedol = value
        case .cusip:
            instrumentProfile.cusip = value
        case .icb:
            instrumentProfile.icb = Int32(InstrumentProfileField.parseNumber(value))
        case .sic:
            instrumentProfile.sic = Int32(InstrumentProfileField.parseNumber(value))
        case .multiplier:
            instrumentProfile.multiplier = InstrumentProfileField.parseNumber(value)
        case .product:
            instrumentProfile.product = value
        case .underlying:
            instrumentProfile.underlying = value
        case .spc:
            instrumentProfile.spc = InstrumentProfileField.parseNumber(value)
        case .additionalUnderlyings:
            instrumentProfile.additionalUnderlyings = value
        case .mmy:
            instrumentProfile.mmy = value
        case .expiration:
            instrumentProfile.expiration = Int32(InstrumentProfileField.parseNumber(value))
        case .lastTrade:
            instrumentProfile.lastTrade = Int32(InstrumentProfileField.parseNumber(value))
        case .strike:
            instrumentProfile.strike = InstrumentProfileField.parseNumber(value)
        case .optionType:
            instrumentProfile.optionType = value
        case .expirationStyle:
            instrumentProfile.expirationStyle = value
        case .settlementStyle:
            instrumentProfile.settlementStyle = value
        case .priceIncrements:
            instrumentProfile.priceIncrements = value
        case .tradingHours:
            instrumentProfile.tradingHours = value
        }
    }
    // swiftlint:enable function_body_length

    public func isNumericField() -> Bool {
        return InstrumentProfileField.numericFields.contains(self)
    }

    public func getNumericField(instrumentProfile: InstrumentProfile) throws -> Double {
        switch self {
        case .icb: return  Double(instrumentProfile.icb)
        case .sic: return  Double(instrumentProfile.sic)
        case .multiplier: return  instrumentProfile.multiplier
        case .spc: return  instrumentProfile.spc
        case .expiration: return  Double(instrumentProfile.expiration)
        case .lastTrade: return  Double(instrumentProfile.lastTrade)
        case .strike: return  instrumentProfile.strike
        default:
            throw ArgumentException.illegalArgumentException
        }
    }

    public func setNumericField(instrumentProfile: InstrumentProfile, value: Double) throws {
        switch self {
        case .icb: return  instrumentProfile.icb = Int32(value)
        case .sic: return  instrumentProfile.sic = Int32(value)
        case .multiplier: return  instrumentProfile.multiplier = value
        case .spc: return  instrumentProfile.spc = value
        case .expiration: return  instrumentProfile.expiration = Int32(value)
        case .lastTrade: return  instrumentProfile.lastTrade = Int32(value)
        case .strike: return  instrumentProfile.strike = value
        default:
            throw ArgumentException.illegalArgumentException
        }
    }
}

extension InstrumentProfileField {
    public static func parseDate(_ value: String) -> Long {
        if value.isEmpty {
            return 0
        }
        if let cached = parsedDates[value] {
            return cached.binary
        } else {
            guard let date = dateFormatter.date(from: value) else {
                return 0
            }
            parsedDates[value] = Entry(text: value, binary: Long(date.millisecondsSince1970) / TimeUtil.day)
            return parsedDates[value]?.binary ?? 0
        }
    }

    public static func formatDate(_ value: Long) -> String {
        if value == 0 {
            return ""
        }
        if let cached = formatedDates[String(value)] {
            return cached.text
        } else {
            let date = Date(millisecondsSince1970: value * TimeUtil.day)
            let stringValue = dateFormatter.string(from: date)
            formatedDates[stringValue] = Entry(text: stringValue, binary: value)
            return stringValue
        }
    }

    public static func parseNumber(_ value: String) -> Double {
        if value.isEmpty {
            return 0
        }
        if let cached = parsedNumbers[value] {
            return Double.longBitsToDouble(cached.binary)
        } else {
            parsedNumbers[value] = Entry(text: value, binary: Double.doubleToLongBits(value: Double(value) ?? 0))
            return Double.longBitsToDouble(parsedNumbers[value]?.binary ?? 0)
        }
    }

    public static func formatNumber(_ value: Double) -> String {
        if value == 0 {
            return ""
        }
        let binary = Double.doubleToLongBits(value: value)
        if let cached = formatedNumbers[String(binary)] {
            return cached.text
        } else {
            let valueStr = formatNumberImpl(value)
            formatedNumbers[valueStr] = Entry(text: valueStr, binary: binary)
            return valueStr
        }
    }

    static func formatNumberImpl(_ value: Double) -> String {
        if value == Double(Int(value)) {
            return String(Int(value))
        }
        if value == Double(Long(value)) {
            return String(Long(value))
        }
        let absValue = abs(value)
        if absValue > 1e-9 && absValue < 1e12 {
            return numberFormatter.string(from: NSNumber(value: value)) ?? ""
        }
        return String(value)
    }
}
