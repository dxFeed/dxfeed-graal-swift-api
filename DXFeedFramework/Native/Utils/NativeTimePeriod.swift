//
//  NativeTimePeriod.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 20.11.23.
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
        let timePeriod = try ErrorCheck.nativeCall(thread, dxfg_TimePeriod_valueOf(thread, value))
        self.init(native: timePeriod)
    }

    convenience init(value: String) throws {
        let thread = currentThread()
        let timePeriod = try ErrorCheck.nativeCall(thread, dxfg_TimePeriod_valueOf2(thread, value.toCStringRef()))
        self.init(native: timePeriod)
    }
}
