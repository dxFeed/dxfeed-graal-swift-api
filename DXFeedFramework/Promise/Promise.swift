//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation

class Promise {
    public typealias PromiseHandler =  (_: Promise) -> Void

    private let native: NativePromise

    internal init(native: NativePromise) {
        self.native = native
    }

    public func getResult() -> MarketEvent? {
        return native.getResult()
    }

    public func hasResult() -> Bool {
        return native.hasResult()
    }

    public func hasException() -> Bool {
        return native.hasException()
    }

    public func isCancelled() -> Bool {
        return native.isCancelled()
    }

    public func getException() -> GraalException? {
        return native.getException()
    }

    public func await() throws -> MarketEvent? {
        return try native.await()
    }

    public func await(millis timeOut: Int32) throws -> MarketEvent? {
        return try native.await(millis: timeOut)
    }

    public func awaitWithoutException(millis timeOut: Int32) {
        return native.awaitWithoutException(millis: timeOut)
    }

    public func cancel() {
        native.cancel()
    }

    public func complete(result: MarketEvent) throws {
        try native.complete(result: result)
    }

    public func completeExceptionally(_ exception: GraalException) throws {
        try native.completeExceptionally(exception)
    }

    public func whenDone(handler: @escaping PromiseHandler) {
        native.whenDone { nativePromise in
            handler(Promise(native: nativePromise))
        }
    }

    public static func completed(result: MarketEvent) -> Promise? {
        if let native = NativePromise.completed(result: result) {
            return Promise(native: native)
        } else {
            return nil
        }
    }

    public static func failed(exception: GraalException) -> Promise? {
        if let native = NativePromise.failed(exception: exception) {
            return Promise(native: native)
        } else {
            return nil
        }
    }

    public static func allOf(promises: [Promise]) throws -> Promise? {
        if let native = try NativePromise.allOf(promises: promises.map { $0.native } ) {
            return Promise(native: native)
        } else {
            return nil
        }
    }

}
