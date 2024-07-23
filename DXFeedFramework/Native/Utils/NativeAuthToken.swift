//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation
@_implementationOnly import graal_api

class NativeAuthToken: NativeBox<dxfg_auth_token_t> {
    deinit {
        let thread = currentThread()
        _ = try? ErrorCheck.nativeCall(thread, dxfg_JavaObjectHandler_release(thread, &(native.pointee.handler)))
    }

    static func valueOf(_ value: String) throws -> NativeAuthToken {
        let thread = currentThread()
        let native = try ErrorCheck.nativeCall(thread, dxfg_AuthToken_valueOf(thread, value.toCStringRef())).value()
        return NativeAuthToken(native: native)
    }

    static func createBasicToken(_ userPassword: String) throws -> NativeAuthToken {
        let thread = currentThread()
        let native = try ErrorCheck.nativeCall(thread,
                                               dxfg_AuthToken_createBasicToken(thread,
                                                                               userPassword.toCStringRef())).value()
        return NativeAuthToken(native: native)
    }

    static func createBasicToken(_ user: String, _ password: String) throws -> NativeAuthToken {
        let thread = currentThread()
        let native = try ErrorCheck.nativeCall(thread,
                                               dxfg_AuthToken_createBasicToken2(thread,
                                                                                user.toCStringRef(),
                                                                                password.toCStringRef())).value()
        return NativeAuthToken(native: native)
    }

    static func createBasicToken(_ user: String, _ password: String) throws -> NativeAuthToken? {
        let thread = currentThread()
        if let native = try ErrorCheck.nativeCall(thread,
                                                  dxfg_AuthToken_createBasicTokenOrNull(thread,
                                                                                        user.toCStringRef(),
                                                                                        password.toCStringRef())) {
            return NativeAuthToken(native: native)
        }
        return nil
    }

    static func createBearerToken(_ token: String) throws -> NativeAuthToken {
        let thread = currentThread()
        let native = try ErrorCheck.nativeCall(thread, dxfg_AuthToken_createBearerToken(thread,
                                                                                        token.toCStringRef())).value()
        return NativeAuthToken(native: native)
    }

    static func createBearerToken(_ token: String) throws -> NativeAuthToken? {
        let thread = currentThread()
        if let native = try ErrorCheck.nativeCall(thread,
                                                  dxfg_AuthToken_createBearerTokenOrNull(thread,
                                                                                         token.toCStringRef())) {
            return NativeAuthToken(native: native)
        }
        return nil
    }

    static func createCustomToken(_ scheme: String, _ value: String) throws -> NativeAuthToken {
        let thread = currentThread()
        let native = try ErrorCheck.nativeCall(thread, dxfg_AuthToken_createCustomToken(thread,
                                                                                        scheme.toCStringRef(),
                                                                                        value.toCStringRef())).value()
        return NativeAuthToken(native: native)
    }

    lazy var user: String? = {
        let thread = currentThread()
        let nativeValue = try? ErrorCheck.nativeCall(thread, dxfg_AuthToken_getUser(thread, native))
        return String(nullable: nativeValue)
    }()

    lazy var password: String? = {
        let thread = currentThread()
        let nativeValue = try? ErrorCheck.nativeCall(thread, dxfg_AuthToken_getPassword(thread, native))
        return String(nullable: nativeValue)
    }()

    lazy var httpAuthorization: String? = {
        let thread = currentThread()
        let nativeValue = try? ErrorCheck.nativeCall(thread, dxfg_AuthToken_getHttpAuthorization(thread, native))
        return String(nullable: nativeValue)
    }()

    lazy var scheme: String? = {
        let thread = currentThread()
        let nativeValue = try? ErrorCheck.nativeCall(thread, dxfg_AuthToken_getScheme(thread, native))
        return String(nullable: nativeValue)
    }()

    lazy var value: String? = {
        let thread = currentThread()
        let nativeValue = try? ErrorCheck.nativeCall(thread, dxfg_AuthToken_getValue(thread, native))
        return String(nullable: nativeValue)
    }()
}
