//
//  NativeDay.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 18.09.23.
//

import Foundation
@_implementationOnly import graal_api

class NativeDay {
    let native: UnsafeMutablePointer<dxfg_day_t>

    init(native: UnsafeMutablePointer<dxfg_day_t>) {
        self.native = native
    }

    deinit {
        let thread = currentThread()
        _ = try? ErrorCheck.nativeCall(thread, dxfg_JavaObjectHandler_release(thread, &(native.pointee.handler)))
    }

}
