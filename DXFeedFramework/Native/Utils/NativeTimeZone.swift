//
//  NativeTimeZone.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 20.11.23.
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
        let native = try ErrorCheck.nativeCall(thread, dxfg_TimeZone_getTimeZone(thread, timeZoneID.toCStringRef()))
        self.init(native: native)
    }
}
