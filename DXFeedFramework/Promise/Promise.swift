//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation

/// Result of a computation that will be completed normally or exceptionally in the future.
/// This class is designed to represent a promise to deliver certain result.
public class Promise {
    public typealias PromiseHandler =  (_: Promise) -> Void

    private let native: NativePromise
    private var handlers = [PromiseHandler]()

    deinit {
        NativePromise.removeListener(listener: self)
    }

    internal init(native: NativePromise) {
        self.native = native
    }

    /// Returns results of computation. If computation has no result, then this method returns nil.
    public func getResults() throws -> [MarketEvent]? {
        return try native.getResults()
    }

    /// Returns results of computation. If computation has no result, then this method returns nil.
    public func getResult() throws -> MarketEvent? {
        return try native.getResult()
    }
    /// Returns **true** when computation has
    /// ``complete(result:)`` completed normally,
    /// or ``completeExceptionally(_:)`` exceptionally,
    /// or was ``cancel()`` canceled
    public func isDone() -> Bool {
        return native.isDone()
    }
    /// Returns **true** when computation has completed normally.
    /// Use ``hasResult()`` method to get the result of the computation.
    public func hasResult() -> Bool {
        return native.hasResult()
    }
    /// Returns **true** when computation has completed exceptionally or was cancelled.
    /// Use ``getException()`` method to get the exceptional outcome of the computation.
    public func hasException() -> Bool {
        return native.hasException()
    }
    /// Returns **true** when computation was canceled.
    /// Use ``getException()`` method to get the corresponding exception.
    public func isCancelled() -> Bool {
        return native.isCancelled()
    }

    /// Returns exceptional outcome of computation. If computation has no  ``hasException()`` exception,
    /// then this method returns ``nil``. If computation has completed exceptionally or was cancelled, then
    /// the result of this method is not ``nil``.
    /// If computation was ``isCancelled()`` cancelled, then this method returns an
    // instance of GraalException.
    /// - Returns: GraalException. Rethrows exception from Java.
    public func getException() -> GraalException? {
        return native.getException()
    }
    
    /// Wait for computation to complete and return its result or throw an exception in case of exceptional completion.
    /// This method waits forever.
    /// - Returns: result of computation.
    /// - Throws : GraalException. Rethrows exception from Java
    public func await() throws -> MarketEvent? {
        if try native.await() {
            return try getResult()
        }
        return nil
    }

    /// Wait for computation to complete and return its result or throw an exception in case of exceptional completion.
    /// If the wait times out, then the computation is ``cancel()`` cancelled and exception is thrown.
    /// - Returns: result of computation.
    /// - Throws : GraalException. Rethrows exception from Java
    public func await(millis timeOut: Int32) throws -> MarketEvent? {
        if try native.await(millis: timeOut) {
            return try getResult()
        }
        return nil
    }
    /// Wait for computation to complete and return its result or throw an exception in case of exceptional completion.
    /// If the wait times out, then the computation is ``cancel()`` cancelled and exception is thrown.
    /// - Returns: If the wait times out, then the computation is ``cancel()`` cancelled and this method returns **false**.
    /// Use this method in the code that shall continue normal execution in case of timeout.
    public func awaitWithoutException(millis timeOut: Int32) -> Bool {
        return native.awaitWithoutException(millis: timeOut)
    }
    /// Cancels computation. This method does nothing if computation has already ``isDone()`` completed.
    public func cancel() {
        native.cancel()
    }
    /// Completes computation normally with a specified result.
    /// This method does nothing if computation has already ``isDone()`` completed
    /// (normally, exceptionally, or was cancelled),
    /// - Throws : GraalException. Rethrows exception from Java
    public func complete(result: MarketEvent) throws {
        try native.complete(result: result)
    }
    /// Completes computation exceptionally with a specified exception.
    /// This method does nothing if computation has already ``isDone()`` completed,
    /// otherwise ``getException()`` will return the specified exception.
    /// - Throws : GraalException. Rethrows exception from Java
    public func completeExceptionally(_ exception: GraalException) throws {
        try native.completeExceptionally(exception)
    }

    /// Registers a handler to be invoked exactly once when computation ``isDone()`` completes.
    /// The handler's  method is invoked immediately when this computation has already completed,
    /// otherwise it will be invoked **synchronously** in the future when computation
    /// ``complete(result:)`` completes normally,
    /// or ``completeExceptionally(_:)`` exceptionally,
    /// or is ``cancel()`` cancelled from the same thread that had invoked one of the completion methods.
    public func whenDone(handler: @escaping PromiseHandler) {
        handlers.append(handler)
        native.whenDone(handler: self)
    }

    /// Returns a new promise that ``isDone()`` completes when all promises from the given array
    /// complete normally or exceptionally.
    /// The results of the given promises are not reflected in the returned promise, but may be
    /// obtained by inspecting them individually. If no promises are provided, returns a promise completed
    /// with the value null.
    /// When the resulting promise completes for any reason ``cancel()`` canceled, for example)
    /// then all of the promises from the given array are canceled.
    /// - Throws : GraalException. Rethrows exception from Java
    public static func allOf(promises: [Promise]) throws -> Promise? {
        if let native = try NativePromise.allOf(promises: promises.map { $0.native }) {
            return Promise(native: native)
        } else {
            return nil
        }
    }

}

extension Promise: PromiseListener {
    func finished() {
        handlers.forEach { handler in
            handler(self)
        }
    }
}
