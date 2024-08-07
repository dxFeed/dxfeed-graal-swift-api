//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
@_implementationOnly import graal_api

class NativeTimeFormat: NativeBox<dxfg_time_format_t> {
    deinit {
        let thread = currentThread()
        _ = try? ErrorCheck.nativeCall(thread, dxfg_JavaObjectHandler_release(thread, &(native.pointee.handler)))
    }

    static func defaultTimeFormat() -> NativeTimeFormat? {
        let thread = currentThread()
        if let native = try? ErrorCheck.nativeCall(thread, dxfg_TimeFormat_DEFAULT(thread)) {
            return NativeTimeFormat(native: native)
        } else {
            return nil
        }
    }

    static func gmtTimeFormat() -> NativeTimeFormat? {
        let thread = currentThread()
        if let native = try? ErrorCheck.nativeCall(thread, dxfg_TimeFormat_GMT(thread)) {
            return NativeTimeFormat(native: native)
        } else {
            return nil
        }
    }

    convenience init(timeZone: NativeTimeZone) throws {
        let thread = currentThread()
        let timeFormat = try ErrorCheck.nativeCall(thread, dxfg_TimeFormat_getInstance(thread, timeZone.native)).value()
        self.init(native: timeFormat)
    }

    convenience init(withTimeZone timeFormat: NativeTimeFormat) throws {
        let thread = currentThread()
        let timeFormat = try ErrorCheck.nativeCall(thread,
                                                   dxfg_TimeFormat_withTimeZone(thread,
                                                                                timeFormat.native)).value()
        self.init(native: timeFormat)
    }

    convenience init(withMillis timeFormat: NativeTimeFormat) throws {
        let thread = currentThread()
        let timeFormat = try ErrorCheck.nativeCall(thread,
                                                   dxfg_TimeFormat_withMillis(thread,
                                                                              timeFormat.native)).value()
        self.init(native: timeFormat)
    }

    convenience init(fullIso timeFormat: NativeTimeFormat) throws {
        let thread = currentThread()
        let timeFormat = try ErrorCheck.nativeCall(thread, dxfg_TimeFormat_asFullIso(thread, timeFormat.native)).value()
        self.init(native: timeFormat)
    }

}
