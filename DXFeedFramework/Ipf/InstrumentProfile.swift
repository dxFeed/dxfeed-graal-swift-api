//
//  InstrumentProfile.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 29.08.23.
//

import Foundation

public enum IPFType: Equatable {
    case stock
    case future
    case option
    case undefined(value: String)

    static func valueOf(str: String) -> IPFType {
        switch str {
        case "STOCK":
            return .stock
        case "FUTURE":
            return .future
        case "OPTION":
            return .option
        default:
            return .undefined(value: str)
        }
    }
}

public class InstrumentProfile {
    var type = "" {
        didSet {
            ipfType = IPFType.valueOf(str: type)
        }
    }
    var symbol = ""
    var descriptionStr = ""
    var localSymbol = ""
    var localDescription = ""
    var country = ""
    var opol = ""
    var exchangeData = ""
    var exchanges = ""
    var currency = ""
    var baseCurrency = ""
    var cfi = ""
    var isin = ""
    var sedol = ""
    var cusip = ""
    var icb: Int32 = 0
    var sic: Int32 = 0
    var multiplier: Double = 0
    var product = ""
    var underlying = ""
    var spc: Double = 0
    var additionalUnderlyings = ""
    var mmy = ""
    var expiration: Int32 = 0
    var lastTrade: Int32 = 0
    var strike: Double = 0
    var optionType = ""
    var expirationStyle = ""
    var settlementStyle = ""
    var priceIncrements = ""
    var tradingHours = ""

    var customFields = [String: String]()

    var ipfType: IPFType?
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

    public func getField(_ name: String) -> String {
        if let ipfField = InstrumentProfileField.find(name) {
            return ipfField.getField(instrumentProfile: self)
        }
        return customFields[name] ?? ""
    }

    public func setField(_ name: String, _ value: String) {
        if let ipfField = InstrumentProfileField.find(name) {
            ipfField.setField(instrumentProfile: self, value: value)
        } else {
            customFields[name] = value
        }
    }

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

    public func setNumericField(_ name: String, _ value: Double) {
        if let ipfField = InstrumentProfileField.find(name) {
            try? ipfField.setNumericField(instrumentProfile: self, value: value)
        } else {
            setField(name, InstrumentProfileField.formatNumber(value))
        }
    }

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

    public func setDateField(_ name: String, _ value: Long) {
        if let ipfField = InstrumentProfileField.find(name) {
            try? ipfField.setNumericField(instrumentProfile: self, value: Double(value))
        } else {
            setField(name, InstrumentProfileField.formatDate(value))
        }
    }

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
            return lhs.ipfType == rhs.ipfType &&
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
