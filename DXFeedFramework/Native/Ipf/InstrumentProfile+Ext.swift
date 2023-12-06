//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
        localSymbol = String(pointee: native.local_symbol)
        localDescription = String(pointee: native.local_description)
        country = String(pointee: native.country)
        opol = String(pointee: native.opol)
        exchangeData = String(pointee: native.exchange_data)
        exchanges = String(pointee: native.exchanges)
        currency = String(pointee: native.currency)
        baseCurrency = String(pointee: native.base_currency)
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
        additionalUnderlyings = String(pointee: native.additional_underlyings)
        mmy = String(pointee: native.mmy)
        expiration = native.expiration
        lastTrade = native.last_trade
        strike = native.strike
        optionType = String(pointee: native.option_type)
        expirationStyle = String(pointee: native.expiration_style)
        settlementStyle = String(pointee: native.settlement_style)
        priceIncrements = String(pointee: native.price_increments)
        tradingHours = String(pointee: native.trading_hours)
        var customFields = [String: String]()
        let count = native.custom_fields.pointee.size
        for index in 0..<Int(count) where index&1 != 1 {
            if let keyElement = native.custom_fields.pointee.elements[index] {
                let key = String(pointee: keyElement)
                if index == count - 1 {
                    customFields[key] = ""
                } else if let valueElement = native.custom_fields.pointee.elements[index + 1] {
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
        pointer.pointee.local_symbol = localSymbol.toCStringRef()
        pointer.pointee.local_description = localDescription.toCStringRef()
        pointer.pointee.country = country.toCStringRef()
        pointer.pointee.opol = opol.toCStringRef()
        pointer.pointee.exchange_data = exchangeData.toCStringRef()
        pointer.pointee.exchanges = exchanges.toCStringRef()
        pointer.pointee.currency = currency.toCStringRef()
        pointer.pointee.base_currency = baseCurrency.toCStringRef()
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
        pointer.pointee.additional_underlyings = additionalUnderlyings.toCStringRef()
        pointer.pointee.mmy = mmy.toCStringRef()
        pointer.pointee.expiration = expiration
        pointer.pointee.last_trade = lastTrade
        pointer.pointee.strike = strike
        pointer.pointee.option_type = optionType.toCStringRef()
        pointer.pointee.expiration_style = expirationStyle.toCStringRef()
        pointer.pointee.settlement_style = settlementStyle.toCStringRef()
        pointer.pointee.price_increments = priceIncrements.toCStringRef()
        pointer.pointee.trading_hours = tradingHours.toCStringRef()
        let list = UnsafeMutablePointer<dxfg_string_list>.allocate(capacity: 1)
        list.pointee.size = 0
        list.pointee.elements = nil
        pointer.pointee.custom_fields = list
    }
}
