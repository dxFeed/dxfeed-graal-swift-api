//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
@_implementationOnly import graal_api

class NativeTimePeriod: NativeBox<dxfg_time_period_t> {
    deinit {
        let thread = currentThread()
        _ = try? ErrorCheck.nativeCall(thread, dxfg_JavaObjectHandler_release(thread, &(native.pointee.handler)))
    }

    static func zero() -> NativeTimePeriod? {
        let thread = currentThread()
        if let native = try? ErrorCheck.nativeCall(thread, dxfg_TimePeriod_ZERO(thread)) {
            return NativeTimePeriod(native: native)
        } else {
            return nil
        }
    }

    static func unlimited() -> NativeTimePeriod? {
        let thread = currentThread()
        if let native = try? ErrorCheck.nativeCall(thread, dxfg_TimePeriod_UNLIMITED(thread)) {
            return NativeTimePeriod(native: native)
        } else {
            return nil
        }
    }

    convenience init(value: Int64) throws {
        let thread = currentThread()
        let timePeriod = try ErrorCheck.nativeCall(thread, dxfg_TimePeriod_valueOf(thread, value)).value()
        self.init(native: timePeriod)
    }

    convenience init(value: String) throws {
        let thread = currentThread()
        let timePeriod = try ErrorCheck.nativeCall(thread, dxfg_TimePeriod_valueOf2(thread, value.toCStringRef())).value()
        self.init(native: timePeriod)
    }

    func getTime() throws -> Long {
        let thread = currentThread()
        let result = try ErrorCheck.nativeCall(thread, dxfg_TimePeriod_getTime(thread, native))
        return result
    }

    func getSeconds() throws -> Int32 {
        let thread = currentThread()
        let result = try ErrorCheck.nativeCall(thread, dxfg_TimePeriod_getSeconds(thread, native))
        return result
    }

    func getNanos() throws -> Long {
        let thread = currentThread()
        let result = try ErrorCheck.nativeCall(thread, dxfg_TimePeriod_getNanos(thread, native))
        return result
    }
}
