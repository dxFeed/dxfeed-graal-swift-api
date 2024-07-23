//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
@_implementationOnly import graal_api

class NativeInstrumentProfile: NativeBox<dxfg_instrument_profile_t> {
    deinit {
        let thread = currentThread()
        _ = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_release(thread, native))
    }

    convenience init() throws {
        let thread = currentThread()
        let result = try ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_new(thread)).value()
        self.init(native: result)
    }

    override init(native: UnsafeMutablePointer<dxfg_instrument_profile_t>) {
        super.init(native: native)
    }

    func toString() -> String {
        let thread = currentThread()
        let value = try? ErrorCheck.nativeCall(thread, dxfg_Object_toString(thread, &(native.pointee.handler)))
        return String(pointee: value, default: "Empty toString for \(self)")
    }
}

extension NativeInstrumentProfile {
    var type: String {
        get {
            let thread = currentThread()
            let value = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_getType(thread, native))
            return String(pointee: value)
        }
        set {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread,
                                           dxfg_InstrumentProfile_setType(thread,
                                                                          native,
                                                                          newValue.toCStringRef()))
        }
    }

    var symbol: String {
        get {
            let thread = currentThread()
            let value = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_getSymbol(thread, native))
            return String(pointee: value)
        }
        set {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_setSymbol(thread, native, newValue))
        }
    }

    var descriptionString: String {
        get {
            let thread = currentThread()
            let value = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_getDescription(thread, native))
            return String(pointee: value)
        }
        set {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_setDescription(thread, native, newValue))
        }
    }

    var localSymbol: String {
        get {
            let thread = currentThread()
            let value = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_getLocalSymbol(thread, native))
            return String(pointee: value)
        }
        set {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_setLocalSymbol(thread, native, newValue))
        }
    }

    var localDescription: String {
        get {
            let thread = currentThread()
            let value = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_getLocalDescription(thread, native))
            return String(pointee: value)
        }
        set {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_setLocalDescription(thread, native, newValue))
        }
    }

    var country: String {
        get {
            let thread = currentThread()
            let value = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_getCountry(thread, native))
            return String(pointee: value)
        }
        set {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_setCountry(thread, native, newValue))
        }
    }
    var oPOL: String {
        get {
            let thread = currentThread()
            let value = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_getOPOL(thread, native))
            return String(pointee: value)
        }
        set {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_setOPOL(thread, native, newValue))
        }
    }
    var exchangeData: String {
        get {
            let thread = currentThread()
            let value = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_getExchangeData(thread, native))
            return String(pointee: value)
        }
        set {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_setExchangeData(thread, native, newValue))
        }
    }
    var exchanges: String {
        get {
            let thread = currentThread()
            let value = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_getExchanges(thread, native))
            return String(pointee: value)
        }
        set {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_setExchanges(thread, native, newValue))
        }
    }
    var currency: String {
        get {
            let thread = currentThread()
            let value = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_getCurrency(thread, native))
            return String(pointee: value)
        }
        set {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_setCurrency(thread, native, newValue))
        }
    }
    var baseCurrency: String {
        get {
            let thread = currentThread()
            let value = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_getBaseCurrency(thread, native))
            return String(pointee: value)
        }
        set {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_setBaseCurrency(thread, native, newValue))
        }
    }
    var cFI: String {
        get {
            let thread = currentThread()
            let value = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_getCFI(thread, native))
            return String(pointee: value)
        }
        set {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_setCFI(thread, native, newValue))
        }
    }
    var iSIN: String {
        get {
            let thread = currentThread()
            let value = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_getISIN(thread, native))
            return String(pointee: value)
        }
        set {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_setISIN(thread, native, newValue))
        }
    }
    var sEDOL: String {
        get {
            let thread = currentThread()
            let value = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_getSEDOL(thread, native))
            return String(pointee: value)
        }
        set {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_setSEDOL(thread, native, newValue))
        }
    }
    var cUSIP: String {
        get {
            let thread = currentThread()
            let value = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_getCUSIP(thread, native))
            return String(pointee: value)
        }
        set {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_setCUSIP(thread, native, newValue))
        }
    }
    var iCB: Int32 {
        get {
            let thread = currentThread()
            let value = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_getICB(thread, native))
            return value ?? 0
        }
        set {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_setICB(thread, native, newValue))
        }
    }
    var sIC: Int32 {
        get {
            let thread = currentThread()
            let value = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_getSIC(thread, native))
            return value ?? 0
        }
        set {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_setSIC(thread, native, newValue))
        }
    }
    var multiplier: Double {
        get {
            let thread = currentThread()
            let value = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_getMultiplier(thread, native))
            return value ?? 0
        }
        set {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_setMultiplier(thread, native, newValue))
        }
    }
    var product: String {
        get {
            let thread = currentThread()
            let value = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_getProduct(thread, native))
            return String(pointee: value)
        }
        set {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_setProduct(thread, native, newValue))
        }
    }
    var underlying: String {
        get {
            let thread = currentThread()
            let value = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_getUnderlying(thread, native))
            return String(pointee: value)
        }
        set {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_setUnderlying(thread, native, newValue))
        }
    }
    var sPC: Double {
        get {
            let thread = currentThread()
            let value = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_getSPC(thread, native))
            return value ?? 0
        }
        set {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_setSPC(thread, native, newValue))
        }
    }
    var additionalUnderlyings: String {
        get {
            let thread = currentThread()
            let value = try? ErrorCheck.nativeCall(thread,
                                                   dxfg_InstrumentProfile_getAdditionalUnderlyings(thread,
                                                                                                   native))
            return String(pointee: value)
        }
        set {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread,
                                           dxfg_InstrumentProfile_setAdditionalUnderlyings(thread,
                                                                                           native,
                                                                                           newValue))
        }
    }
    var mMY: String {
        get {
            let thread = currentThread()
            let value = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_getMMY(thread, native))
            return String(pointee: value)
        }
        set {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_setMMY(thread, native, newValue))
        }
    }
    var expiration: Int32 {
        get {
            let thread = currentThread()
            let value = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_getExpiration(thread, native))
            return value ?? 0
        }
        set {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_setExpiration(thread, native, newValue))
        }
    }
    var lastTrade: Int32 {
        get {
            let thread = currentThread()
            let value = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_getLastTrade(thread, native))
            return value ?? 0
        }
        set {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_setLastTrade(thread, native, newValue))
        }
    }
    var strike: Double {
        get {
            let thread = currentThread()
            let value = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_getStrike(thread, native))
            return value ?? 0
        }
        set {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_setStrike(thread, native, newValue))
        }
    }
    var optionType: String {
        get {
            let thread = currentThread()
            let value = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_getOptionType(thread, native))
            return String(pointee: value)
        }
        set {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_setOptionType(thread, native, newValue))
        }
    }
    var expirationStyle: String {
        get {
            let thread = currentThread()
            let value = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_getExpirationStyle(thread, native))
            return String(pointee: value)
        }
        set {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_setExpirationStyle(thread, native, newValue))
        }
    }
    var settlementStyle: String {
        get {
            let thread = currentThread()
            let value = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_getSettlementStyle(thread, native))
            return String(pointee: value)
        }
        set {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_setSettlementStyle(thread, native, newValue))
        }
    }
    var priceIncrements: String {
        get {
            let thread = currentThread()
            let value = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_getPriceIncrements(thread, native))
            return String(pointee: value)
        }
        set {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_setPriceIncrements(thread, native, newValue))
        }
    }
    var tradingHours: String {
        get {
            let thread = currentThread()
            let value = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_getTradingHours(thread, native))
            return String(pointee: value)
        }
        set {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_setTradingHours(thread, native, newValue))
        }
    }
}

extension NativeInstrumentProfile {
    /// Returns field value with a specified name.
    func getField(_ name: String) -> String {
        let thread = currentThread()
        let value = try? ErrorCheck.nativeCall(thread,
                                               dxfg_InstrumentProfile_getField(thread,
                                                                               native,
                                                                               name.toCStringRef()))
        return String(pointee: value)
    }
    /// Changes field value with a specified name.
    func setField(_ name: String, _ value: String) {
        let thread = currentThread()
        _ = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_setField(thread,
                                                                           native,
                                                                           name.toCStringRef(),
                                                                           value.toCStringRef()))
    }
    /// Returns numeric field value with a specified name.
    func getNumericField(_ name: String) -> Double {
        let thread = currentThread()
        let value = try? ErrorCheck.nativeCall(thread,
                                               dxfg_InstrumentProfile_getNumericField(thread,
                                                                                      native,
                                                                                      name.toCStringRef()))
        return value ?? 0
    }
    /// Changes numeric field value with a specified name.
    func setNumericField(_ name: String, _ value: Double) {
        let thread = currentThread()
        _ = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_setNumericField(thread,
                                                                           native,
                                                                           name.toCStringRef(),
                                                                           value))
    }
    /// Returns day id value for a date field with a specified name.
    func getDateField(_ name: String) -> Int32 {
        let thread = currentThread()
        let value = try? ErrorCheck.nativeCall(thread,
                                               dxfg_InstrumentProfile_getDateField(thread,
                                                                                   native,
                                                                                   name.toCStringRef()))
        return value ?? 0
    }
    /// Changes day id value for a date field with a specified name.
    func setDateField(_ name: String, _ value: Int32) {
        let thread = currentThread()
        _ = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_setDateField(thread,
                                                                                   native,
                                                                                   name.toCStringRef(),
                                                                                   value))
    }
    /// Adds names of non-empty custom fields to specified collection.
    func addNonEmptyCustomFieldNames(_ targetFieldNames: inout [String]) -> Bool {
        let thread = currentThread()
        if let value = try? ErrorCheck.nativeCall(thread,
                                                  dxfg_InstrumentProfile_getNonEmptyCustomFieldNames(thread,
                                                                                                     native)) {
            for index in 0..<Int(value.pointee.size) {
                targetFieldNames.append(String(pointee: value.pointee.elements[index]))
            }
            defer {
                _ = try? ErrorCheck.nativeCall(thread, dxfg_CList_String_release(thread, value))
            }
            return value.pointee.size != 0
        }
        return false
    }

}

extension NativeInstrumentProfile: Hashable {
    static func == (lhs: NativeInstrumentProfile, rhs: NativeInstrumentProfile) -> Bool {
        if lhs === rhs {
            return true
        } else {
            let thread = currentThread()
            let isEqual = try? ErrorCheck.nativeCall(thread,
                                                     dxfg_Object_equals(thread,
                                                                        &(lhs.native.pointee.handler),
                                                                        &(rhs.native.pointee.handler)))
            return (isEqual ?? 0) == 1
        }
    }

    func hash(into hasher: inout Hasher) {
        let thread = currentThread()
        let hash = try? ErrorCheck.nativeCall(thread, dxfg_Object_hashCode(thread, &(native.pointee.handler)))
        hasher.combine(hash)
    }
}
