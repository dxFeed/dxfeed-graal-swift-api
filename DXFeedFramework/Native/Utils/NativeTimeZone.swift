//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
@_implementationOnly import graal_api

class NativeTimeZone: NativeBox<dxfg_time_zone_t> {
    deinit {
        let thread = currentThread()
        _ = try? ErrorCheck.nativeCall(thread, dxfg_JavaObjectHandler_release(thread, &(native.pointee.handler)))
    }

    static func defaultTimeZone() -> NativeTimeZone? {
        let thread = currentThread()
        if let native = try? ErrorCheck.nativeCall(thread, dxfg_TimeZone_getDefault(thread)) {
            return NativeTimeZone(native: native)
        } else {
            return nil
        }
    }

    convenience init(timeZoneID: String) throws {
        let thread = currentThread()
        let native = try ErrorCheck.nativeCall(thread, dxfg_TimeZone_getTimeZone(thread, timeZoneID.toCStringRef())).value()
        self.init(native: native)
    }

    func id() throws -> String? {
        let thread = currentThread()
        let result = try ErrorCheck.nativeCall(thread, dxfg_TimeZone_getID(thread, native))
        return String(nullable: result)
    }

    func diplayName() throws -> String? {
        let thread = currentThread()
        let result = try ErrorCheck.nativeCall(thread, dxfg_TimeZone_getDisplayName(thread, native))
        return String(nullable: result)
    }

    func diplayName(dayLight: Int32, style: Int32) throws -> String? {
        let thread = currentThread()
        let result = try ErrorCheck.nativeCall(thread, dxfg_TimeZone_getDisplayName2(thread, native, dayLight, style))
        return String(nullable: result)
    }

    func getDSTSavings() throws -> Int32 {
        let thread = currentThread()
        let result = try ErrorCheck.nativeCall(thread, dxfg_TimeZone_getDSTSavings(thread, native))
        return result
    }

    func useDaylightTime() throws -> Int32 {
        let thread = currentThread()
        let result = try ErrorCheck.nativeCall(thread, dxfg_TimeZone_useDaylightTime(thread, native))
        return result
    }

    func observesDaylightTime() throws -> Int32 {
        let thread = currentThread()
        let result = try ErrorCheck.nativeCall(thread, dxfg_TimeZone_observesDaylightTime(thread, native))
        return result
    }

    func getOffset(date: Int64) throws -> Int32 {
        let thread = currentThread()
        let result = try ErrorCheck.nativeCall(thread, dxfg_TimeZone_getOffset(thread, native, date))
        return result
    }

    func getOffset2(offset: DXDateOffset) throws -> Int32 {
        let thread = currentThread()
        let result = try ErrorCheck.nativeCall(thread, dxfg_TimeZone_getOffset2(thread,
                                                                                native,
                                                                                offset.era,
                                                                                offset.year,
                                                                                offset.month,
                                                                                offset.day,
                                                                                offset.dayOfWeek,
                                                                                offset.milliseconds))
        return result
    }

    func getRawOffset() throws -> Int32 {
        let thread = currentThread()
        let result = try ErrorCheck.nativeCall(thread, dxfg_TimeZone_getRawOffset(thread, native))
        return result
    }

    func hasSameRules(other: NativeTimeZone) throws -> Int32 {
        let thread = currentThread()
        let result = try ErrorCheck.nativeCall(thread, dxfg_TimeZone_hasSameRules(thread, native, other.native))
        return result
    }

    func inDaylightTime(date: Int64) throws -> Int32 {
        let thread = currentThread()
        let result = try ErrorCheck.nativeCall(thread, dxfg_TimeZone_inDaylightTime(thread, native, date))
        return result
    }
    func setID(id: String) throws -> Bool {
        let thread = currentThread()
        let result = try ErrorCheck.nativeCall(thread, dxfg_TimeZone_setID(thread, native, id.toCStringRef()))
        return result == ErrorCheck.Result.success.rawValue
    }

    func setRawOffset(offsetMillis: Int32) throws -> Bool {
        let thread = currentThread()
        let result = try ErrorCheck.nativeCall(thread, dxfg_TimeZone_setRawOffset(thread, native, offsetMillis))
        return result == ErrorCheck.Result.success.rawValue
    }
}
