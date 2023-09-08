//
//  InstrumentProfile.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 29.08.23.
//

import Foundation

public class InstrumentProfile {
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
    public var symbol = ""
    public var descriptionStr = ""
    public var localSymbol = ""
    public var localDescription = ""
    public var country = ""
    public var opol = ""
    public var exchangeData = ""
    public var exchanges = ""
    public var currency = ""
    public var baseCurrency = ""
    public var cfi = ""
    public var isin = ""
    public var sedol = ""
    public var cusip = ""
    public var icb: Int32 = 0
    public var sic: Int32 = 0
    public var multiplier: Double = 0
    public var product = ""
    public var underlying = ""
    public var spc: Double = 0
    public var additionalUnderlyings = ""
    public var mmy = ""
    public var expiration: Int32 = 0
    public var lastTrade: Int32 = 0
    public var strike: Double = 0
    public var optionType = ""
    public var expirationStyle = ""
    public var settlementStyle = ""
    public var priceIncrements = ""
    public var tradingHours = ""

    var customFields = [String: String]()

    public var ipfType: InstrumentProfileType?

    init() {
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
