//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation
@_implementationOnly import graal_api

class NativeOnDemandService {
    private let native: UnsafeMutablePointer<dxfg_on_demand_service_t>

    deinit {
        let thread = currentThread()
        _ = try? ErrorCheck.nativeCall(thread,
                                       dxfg_JavaObjectHandler_release(thread,
                                                                      &(native.pointee.handler)))
    }

    init(native: UnsafeMutablePointer<dxfg_on_demand_service_t>) {
        self.native = native
    }

    static func getInstance() throws -> NativeOnDemandService {
        let thread = currentThread()
        let instance = try ErrorCheck.nativeCall(thread, dxfg_OnDemandService_getInstance(thread)).value()
        return NativeOnDemandService(native: instance)
    }

    static func getInstance(endpoint: NativeEndpoint) throws -> NativeOnDemandService {
        let thread = currentThread()
        let instance = try ErrorCheck.nativeCall(thread, dxfg_OnDemandService_getInstance2(thread, endpoint.endpoint)).value()
        return NativeOnDemandService(native: instance)
    }

    func getEndpoint() throws -> DXEndpoint {
        let thread = currentThread()
        let endpoint = try ErrorCheck.nativeCall(thread, dxfg_OnDemandService_getEndpoint(thread, native)).value()
        let role = try ErrorCheck.nativeCall(thread, dxfg_DXEndpoint_getRole(thread, endpoint))
        return try DXEndpoint(native: NativeEndpoint(endpoint), role: Role.fromNative(role), name: "")
    }

    var isReplaySupported: Bool? {
        let thread = currentThread()
        return try? ErrorCheck.nativeCall(thread, dxfg_OnDemandService_isReplaySupported(thread, native)) == 1
    }

    var isReplay: Bool? {
        let thread = currentThread()
        return try? ErrorCheck.nativeCall(thread, dxfg_OnDemandService_isReplay(thread, native)) == 1
    }

    var isClear: Bool? {
        let thread = currentThread()
        return try? ErrorCheck.nativeCall(thread, dxfg_OnDemandService_isClear(thread, native)) == 1
    }

    var getTime: Date? {
        let thread = currentThread()
        if let value =  try? ErrorCheck.nativeCall(thread, dxfg_OnDemandService_getTime(thread, native)) {
            return Date.init(millisecondsSince1970: value)
        }
        return nil
    }

    var getSpeed: Double? {
        let thread = currentThread()
        return try? ErrorCheck.nativeCall(thread, dxfg_OnDemandService_getSpeed(thread, native))
    }

    func replay(date: Date) throws {
        let thread = currentThread()
        try ErrorCheck.nativeCall(thread, dxfg_OnDemandService_replay(thread, native, Int64(date.millisecondsSince1970)))
    }

    func replay(date: Date, speed: Double) throws {
        let thread = currentThread()
        try ErrorCheck.nativeCall(thread, dxfg_OnDemandService_replay2(thread, native, Int64(date.millisecondsSince1970), speed))
    }

    func pause() throws {
        let thread = currentThread()
        try ErrorCheck.nativeCall(thread, dxfg_OnDemandService_pause(thread, native))
    }

    func stopAndResume() throws {
        let thread = currentThread()
        try ErrorCheck.nativeCall(thread, dxfg_OnDemandService_stopAndResume(thread, native))
    }

    func stopAndClear() throws {
        let thread = currentThread()
        try ErrorCheck.nativeCall(thread, dxfg_OnDemandService_stopAndClear(thread, native))
    }

    func setSpeed(_ speed: Double) throws {
        let thread = currentThread()
        try ErrorCheck.nativeCall(thread, dxfg_OnDemandService_setSpeed(thread, native, speed))
    }
}
