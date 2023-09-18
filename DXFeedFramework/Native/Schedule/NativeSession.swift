//
//  NativeSession.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 18.09.23.
//

import Foundation
@_implementationOnly import graal_api

class NativeSession {
    let native: UnsafeMutablePointer<dxfg_session_t>

    init(native: UnsafeMutablePointer<dxfg_session_t>) {
        self.native = native
    }

    deinit {
        let thread = currentThread()
        _ = try? ErrorCheck.nativeCall(thread, dxfg_JavaObjectHandler_release(thread, &(native.pointee.handler)))
    }
}
