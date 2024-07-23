//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation

/// The ``DXAuthToken`` class represents an authorization token and encapsulates information about the authorization
///  scheme and its associated value.
public class DXAuthToken {
    let native: NativeAuthToken

    private init(native: NativeAuthToken) {
        self.native = native
    }

    /// Constructs an ``DXAuthToken`` from the specified string.
    ///
    /// - Parameters: the string with space-separated scheme and value
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public static func valueOf(_ value: String) throws -> DXAuthToken {
        return DXAuthToken(native: try NativeAuthToken.valueOf(value))
    }

    /// Constructs an ``DXAuthToken`` with the specified username and password per RFC2617.
    /// Username and password can be empty.
    ///
    /// - Parameters: the string containing the username and password in the format "username:password"
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public static func createBasicToken(_ userPassword: String) throws -> DXAuthToken {
        return DXAuthToken(native: try NativeAuthToken.createBasicToken(userPassword))
    }

    /// Constructs an ``DXAuthToken`` with the specified username and password per RFC2617.
    /// Username and password can be empty.
    ///
    /// - Parameters:
    ///    - user: the username
    ///    - password: the password
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public static func createBasicToken(_ user: String, _ password: String) throws -> DXAuthToken {
        return DXAuthToken(native: try NativeAuthToken.createBasicToken(user, password))
    }

    /// Constructs an ``DXAuthToken`` with the specified username and password per RFC2617.
    /// If both the username and password are empty or null, returns null.
    ///
    /// - Parameters:
    ///    - user: the username
    ///    - password: the password
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public static func createBasicToken(_ user: String, _ password: String) throws -> DXAuthToken? {
        if let native = try NativeAuthToken.createBasicToken(user, password) {
            return DXAuthToken(native: native)
        }
        return nil
    }

    /// Constructs an ``DXAuthToken`` with the specified bearer token per RFC6750.
    ///
    /// - Parameters:
    ///    - token: the access token
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public static func createBearerToken(_ token: String) throws -> DXAuthToken {
        return DXAuthToken(native: try NativeAuthToken.createBearerToken(token))
    }

    /// Constructs an ``DXAuthToken`` with the specified bearer token per RFC6750.
    ///
    /// - Parameters:
    ///    - token: the access token
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public static func createBearerToken(_ token: String) throws -> DXAuthToken? {
        if let native = try NativeAuthToken.createBearerToken(token) {
            return DXAuthToken(native: native)
        }
        return nil
    }

    /// Constructs an ``DXAuthToken``with a custom scheme and value.
    ///
    /// - Parameters:
    ///    - scheme: the custom scheme
    ///    - value: the custom value
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public static func createCustomToken(_ scheme: String, _ value: String) throws -> DXAuthToken {
        return DXAuthToken(native: try NativeAuthToken.createCustomToken(scheme, value))
    }

    /// Returns the username or null if it is not known or applicable.
    public lazy var user: String? = {
        return native.user
    }()

    /// Returns the password or null if it is not known or applicable.
    public lazy var password: String? = {
        return native.password
    }()

    /// Returns the HTTP authorization header value.
    public lazy var httpAuthorization: String? = {
        return native.httpAuthorization
    }()

    /// Returns the authentication scheme or null if it is not known or applicable.
    public lazy var scheme: String? = {
        return native.scheme
    }()

    /// Returns the access token for RFC6750 or the Base64-encoded "username:password" for RFC2617.
    public lazy var value: String? = {
        return native.value
    }()
}
