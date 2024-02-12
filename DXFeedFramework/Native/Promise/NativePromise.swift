//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation
@_implementationOnly import graal_api

class NativePromise {
    public typealias PromiseHandler =  (_: NativePromise) -> Void

    let native: UnsafeMutablePointer<dxfg_promise_event_t>?
    let promise: UnsafeMutablePointer<dxfg_promise_t>?

    private static let mapper = EventMapper()

    private class WeakPromises: WeakBox<PromiseHandler> { }
    private static let listeners = ConcurrentArray<WeakPromises>()

    static let listenerCallback: dxfg_promise_handler_function = { _, promise, context in
        if let context = context {
            let listener: AnyObject = bridge(ptr: context)
            if let weakListener =  listener as? WeakPromises {
                guard let listener = weakListener.value else {
                    return
                }
                let native = NativePromise(native: nil, promise: promise)
                listener(native)
                NativePromise.listeners.removeAll(where: {
                    return $0 === weakListener
                })
            }
        }
    }

    deinit {
        if let promise = promise {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(
                thread,
                dxfg_JavaObjectHandler_release(thread,
                                               &(promise.pointee.handler)))
        }
    }

    init(native: UnsafeMutablePointer<dxfg_promise_event_t>?, promise: UnsafeMutablePointer<dxfg_promise_t>?) {
        self.native = native
        self.promise = promise
    }

    func getResult() -> MarketEvent? {
        let thread = currentThread()
        if let result = try? ErrorCheck.nativeCall(thread, dxfg_Promise_EventType_getResult(thread, native)) {
            let marketEvent = try? EventMapper().fromNative(native: result)
            return marketEvent
        } else {
            return nil
        }
    }

    func hasResult() -> Bool {
        let thread = currentThread()
        if let result = try? ErrorCheck.nativeCall(thread, dxfg_Promise_hasResult(thread, promise)) {
            return result == 1
        } else {
            return false
        }
    }

    func hasException() -> Bool {
        let thread = currentThread()
        if let result = try? ErrorCheck.nativeCall(thread, dxfg_Promise_hasException(thread, promise)) {
            return result == 1
        } else {
            return false
        }
    }

    func isCancelled() -> Bool {
        let thread = currentThread()
        if let result = try? ErrorCheck.nativeCall(thread, dxfg_Promise_isCancelled(thread, promise)) {
            return result == 1
        } else {
            return false
        }
    }

    func getException() -> GraalException? {
        let thread = currentThread()
        if let nativeException = try? ErrorCheck.nativeCall(thread, dxfg_Promise_getException(thread, promise)) {
            defer {
                _ = try? ErrorCheck.nativeCall(thread, dxfg_Exception_release(thread, nativeException))
            }
            let exception = GraalException.createNew(native: nativeException)
            return exception
        }
        return nil
    }

    func await() throws -> MarketEvent? {
        let thread = currentThread()
        try ErrorCheck.nativeCall(thread, dxfg_Promise_await(thread, promise))
        return nil
    }

    func await(millis timeOut: Int32) throws -> Bool {
        let thread = currentThread()
        let success = try ErrorCheck.nativeCall(thread, dxfg_Promise_await2(thread, promise, timeOut))
        return success == ErrorCheck.Result.success.rawValue
    }

    func awaitWithoutException(millis timeOut: Int32) {
        let thread = currentThread()
        _ = try? ErrorCheck.nativeCall(thread, dxfg_Promise_awaitWithoutException(thread, promise, timeOut))
    }

    func cancel() {
        let thread = currentThread()
        _ = try? ErrorCheck.nativeCall(thread, dxfg_Promise_cancel(thread, promise))
    }

    func complete(result: MarketEvent) throws {
        let thread = currentThread()
        let nativeEvent = try NativePromise.mapper.toNative(event: result)
        try ErrorCheck.nativeCall(thread, dxfg_Promise_EventType_complete(thread, promise, nativeEvent))
    }

    func completeExceptionally(_ exception: GraalException) throws {
        if let nativeException = exception.toNative() {
            let thread = currentThread()
            try ErrorCheck.nativeCall(thread, dxfg_Promise_completeExceptionally(thread, promise, nativeException))
        } else {
            throw ArgumentException.exception("Coudln't convert to native exception")
        }
    }

    func whenDone(handler: @escaping NativePromise.PromiseHandler) {
        let thread = currentThread()
        let weakListener = WeakPromises(value: handler)
        NativePromise.listeners.append(newElement: weakListener)
        let voidPtr = bridge(obj: weakListener)
        _ = try? ErrorCheck.nativeCall(thread, 
                                       dxfg_Promise_whenDone(thread,
                                                             promise,
                                                             NativePromise.listenerCallback,
                                                             voidPtr))
    }

    static func completed(result: MarketEvent) -> NativePromise? {
        let thread = currentThread()
        let promise = UnsafeMutablePointer<dxfg_promise_t>.allocate(capacity: 1)
        if let nativeEvent = try? NativePromise.mapper.toNative(event: result) {
            let handler = nativeEvent.withMemoryRebound(to: dxfg_java_object_handler.self, capacity: 1) { pointer in
                return pointer
            }
            let result = try? ErrorCheck.nativeCall(thread, dxfg_Promise_completed(thread, promise, handler))
            return NativePromise(native: nil, promise: result)
        }
        return nil
    }

    static func failed(exception: GraalException) -> NativePromise? {
        let thread = currentThread()
        let promise = UnsafeMutablePointer<dxfg_promise_t>.allocate(capacity: 1)
        if let nativeEvent = exception.toNative() {
            let result = try? ErrorCheck.nativeCall(thread, dxfg_Promise_failed(thread, promise, nativeEvent))
            return NativePromise(native: nil, promise: result)
        }
        return nil
    }

    static func allOf(promises: [NativePromise]) throws -> NativePromise? {
        let promiseList = UnsafeMutablePointer<dxfg_promise_list>.allocate(capacity: 1)
        let nativeList = UnsafeMutablePointer<dxfg_java_object_handler_list>.allocate(capacity: 1)
        let classes = UnsafeMutablePointer<UnsafeMutablePointer<dxfg_java_object_handler>?>
            .allocate(capacity: promises.count)
        var iterator = classes
        for code in promises {
            code.promise?.withMemoryRebound(to: dxfg_java_object_handler.self, capacity: 1, { pointer in
                iterator.initialize(to: pointer)
                iterator = iterator.successor()
            })
        }
        nativeList.pointee.size = Int32(promises.count)
        nativeList.pointee.elements = classes
        promiseList.pointee.list = nativeList.pointee

        let thread = currentThread()
        let result = try ErrorCheck.nativeCall(thread, dxfg_Promises_allOf(thread, promiseList))
        return NativePromise(native: nil, promise: result)
    }
}
