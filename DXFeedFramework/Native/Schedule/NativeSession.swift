//
//  NativeSession.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 18.09.23.
//

import Foundation
@_implementationOnly import graal_api

class NativeSession: NativeBox<dxfg_session_t> {
    deinit {
        let thread = currentThread()
        _ = try? ErrorCheck.nativeCall(thread, dxfg_JavaObjectHandler_release(thread, &(native.pointee.handler)))
    }
}
