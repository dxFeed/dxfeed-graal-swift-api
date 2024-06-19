//
//  InstrumentProfile+Ext.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 29.08.23.
//

import Foundation
@_implementationOnly import graal_api

extension InstrumentProfile {
    convenience init(native: dxfg_instrument_profile_t) {
        self.init()
        setValues(native: native)
    }

    private func setValues(native: dxfg_instrument_profile_t) {
        type = String(pointee: native.type)
        symbol = String(pointee: native.symbol)
        descriptionStr = String(pointee: native.description)
        localSymbol = String(pointee: native.localSymbol)
        localDescription = String(pointee: native.localDescription)
        country = String(pointee: native.country)
        opol = String(pointee: native.opol)
        exchangeData = String(pointee: native.exchangeData)
        exchanges = String(pointee: native.exchanges)
        currency = String(pointee: native.currency)
        baseCurrency = String(pointee: native.baseCurrency)
        cfi = String(pointee: native.cfi)
        isin = String(pointee: native.isin)
        sedol = String(pointee: native.sedol)
        cusip = String(pointee: native.cusip)
        icb = native.icb
        sic = native.sic
        multiplier = native.multiplier
        product = String(pointee: native.product)
        underlying = String(pointee: native.underlying)
        spc = native.spc
        additionalUnderlyings = String(pointee: native.additionalUnderlyings)
        mmy = String(pointee: native.mmy)
        expiration = native.expiration
        lastTrade = native.lastTrade
        strike = native.strike
        optionType = String(pointee: native.optionType)
        expirationStyle = String(pointee: native.expirationStyle)
        settlementStyle = String(pointee: native.settlementStyle)
        priceIncrements = String(pointee: native.priceIncrements)
        tradingHours = String(pointee: native.tradingHours)
        var customFields = [String: String]()
        let count = native.customFields.pointee.size
        for index in 0..<Int(count) where index&1 != 1 {
            if let keyElement = native.customFields.pointee.elements[index] {
                let key = String(pointee: keyElement)
                if index == count - 1 {
                    customFields[key] = ""
                } else if let valueElement = native.customFields.pointee.elements[index + 1] {
                    customFields[key] = String(pointee: valueElement)
                }
            }
        }
        self.customFields = customFields
    }

    func copy(to pointer: UnsafeMutablePointer<dxfg_instrument_profile_t>) {
        pointer.pointee.type = type.toCStringRef()
        pointer.pointee.symbol = symbol.toCStringRef()
        pointer.pointee.description = descriptionStr.toCStringRef()
        pointer.pointee.localSymbol = localSymbol.toCStringRef()
        pointer.pointee.localDescription = localDescription.toCStringRef()
        pointer.pointee.country = country.toCStringRef()
        pointer.pointee.opol = opol.toCStringRef()
        pointer.pointee.exchangeData = exchangeData.toCStringRef()
        pointer.pointee.exchanges = exchanges.toCStringRef()
        pointer.pointee.currency = currency.toCStringRef()
        pointer.pointee.baseCurrency = baseCurrency.toCStringRef()
        pointer.pointee.cfi = cfi.toCStringRef()
        pointer.pointee.isin = isin.toCStringRef()
        pointer.pointee.sedol = sedol.toCStringRef()
        pointer.pointee.cusip = cusip.toCStringRef()
        pointer.pointee.icb = icb
        pointer.pointee.sic = sic
        pointer.pointee.multiplier = multiplier
        pointer.pointee.product = product.toCStringRef()
        pointer.pointee.underlying = underlying.toCStringRef()
        pointer.pointee.spc = spc
        pointer.pointee.additionalUnderlyings = additionalUnderlyings.toCStringRef()
        pointer.pointee.mmy = mmy.toCStringRef()
        pointer.pointee.expiration = expiration
        pointer.pointee.lastTrade = lastTrade
        pointer.pointee.strike = strike
        pointer.pointee.optionType = optionType.toCStringRef()
        pointer.pointee.expirationStyle = expirationStyle.toCStringRef()
        pointer.pointee.settlementStyle = settlementStyle.toCStringRef()
        pointer.pointee.priceIncrements = priceIncrements.toCStringRef()
        pointer.pointee.tradingHours = tradingHours.toCStringRef()
        let list = UnsafeMutablePointer<dxfg_string_list>.allocate(capacity: 1)
        list.pointee.size = 0
        list.pointee.elements = nil
        pointer.pointee.customFields = list
    }
}
