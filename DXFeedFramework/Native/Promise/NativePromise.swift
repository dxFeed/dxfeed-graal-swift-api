//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation
@_implementationOnly import graal_api

internal protocol PromiseListener: AnyObject {
    func done()
}

/// Native wrapper over the Java com.dxfeed.promise.Promise class.
/// The location of the imported functions is in the header files "dxfg_feed.h".
class NativePromise {
    private class WeakListener: WeakBox<PromiseListener> { }
    typealias PromiseHandler =  (_: NativePromise) -> Void

    let promise: UnsafeMutablePointer<dxfg_promise_t>?

    private static let mapper = EventMapper()

    private var result: MarketEvent?
    private var results: [MarketEvent]?

    private static let listeners = ConcurrentArray<WeakListener>()

    static let listenerCallback: dxfg_promise_handler_function = { _, promise, context in
        if let context = context {
            ThreadManager.insertPthread()

            let listener: AnyObject = bridge(ptr: context)
            if let weakListener =  listener as? WeakListener {
                defer {
                    NativePromise.listeners.removeAll(where: {
                        return $0 === weakListener
                    })
                }
                guard let listener = weakListener.value else {
                    return
                }
                promise?.withMemoryRebound(to: dxfg_promise_event_t.self, capacity: 1, { pointer in
                    let native = NativePromise(promise: &pointer.pointee.handler)
                    listener.done()
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

    init(promise: UnsafeMutablePointer<dxfg_promise_t>?) {
        self.promise = promise
    }

    func getResults() throws -> [MarketEvent]? {
        if let results = results {
            return results
        }
        let thread = currentThread()
        let res: [MarketEvent]? = try promise?.withMemoryRebound(to: dxfg_promise_events_t.self,
                                                                 capacity: 1, { promiseEvents in
            guard let listPointer = try ErrorCheck.nativeCall(thread,
                                                        dxfg_Promise_List_EventType_getResult(thread,
                                                                                              promiseEvents)) else {
                return nil
            }
            defer {
                _ = try? ErrorCheck.nativeCall(thread, dxfg_CList_EventType_release(thread, listPointer))
            }
            var results = [MarketEvent]()
            let size = listPointer.pointee.size
            for index in 0..<Int(size) {
                if let element = listPointer.pointee.elements[index] {
                    if let marketEvent = try EventMapper().fromNative(native: element) {
                        results.append(marketEvent)
                    }
                }
            }
            self.results = results
            return results
        })
        return res
    }

    func getResult() throws -> MarketEvent? {
        if let result = result {
            return result
        }
        let thread = currentThread()
        let res: MarketEvent? = try promise?.withMemoryRebound(to: dxfg_promise_event_t.self,
                                                               capacity: 1, { promiseEvent in
            guard let result = try ErrorCheck.nativeCall(thread,
                                                         dxfg_Promise_EventType_getResult(thread,
                                                                                          promiseEvent)) else {
                return nil
            }

            let marketEvent = try EventMapper().fromNative(native: result)
            defer {
                _ = try? ErrorCheck.nativeCall(thread, dxfg_EventType_release(thread, result))
            }
            self.result = marketEvent
            return marketEvent

        })
        return res
    }

    func isDone() -> Bool {
        let thread = currentThread()
        if let result = try? ErrorCheck.nativeCall(thread, dxfg_Promise_isDone(thread, promise)) {
            return result == 1
        } else {
            return false
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

    func await() throws -> Bool {
        let thread = currentThread()
        let success = try ErrorCheck.nativeCall(thread, dxfg_Promise_await(thread, promise))
        return success == ErrorCheck.Result.success.rawValue
    }

    func await(millis timeOut: Int32) throws -> Bool {
        let thread = currentThread()
        let success = try ErrorCheck.nativeCall(thread, dxfg_Promise_await2(thread, promise, timeOut))
        return success == ErrorCheck.Result.success.rawValue
    }

    func awaitWithoutException(millis timeOut: Int32) -> Bool {
        let thread = currentThread()
        let success = try? ErrorCheck.nativeCall(thread, dxfg_Promise_awaitWithoutException(thread, promise, timeOut))
        return success == ErrorCheck.Result.success.rawValue
    }

    func cancel() {
        let thread = currentThread()
        _ = try? ErrorCheck.nativeCall(thread, dxfg_Promise_cancel(thread, promise))
    }

    func complete(result: MarketEvent) throws {
        let thread = currentThread()
        if let nativeEvent = try NativePromise.mapper.toNative(event: result) {
            defer {
                NativePromise.mapper.releaseNative(native: nativeEvent)
            }
            try ErrorCheck.nativeCall(thread, dxfg_Promise_EventType_complete(thread, promise, nativeEvent))
        }
    }

    func completeExceptionally(_ exception: GraalException) throws {
        if let nativeException = exception.toNative() {
//            defer {
//                nativeException.deinitialize(count: 1)
//                nativeException.deallocate()
//            }
            let thread = currentThread()
            try ErrorCheck.nativeCall(thread, dxfg_Promise_completeExceptionally(thread, promise, nativeException))
        } else {
            throw ArgumentException.exception("Coudln't convert to native exception")
        }
    }

    func whenDone(handler: PromiseListener) {
        let thread = currentThread()
        let weakListener = WeakListener(value: handler)
        NativePromise.listeners.append(newElement: weakListener)
        let voidPtr = bridge(obj: weakListener)
        _ = try? ErrorCheck.nativeCall(thread,
                                       dxfg_Promise_whenDone(thread,
                                                             promise,
                                                             NativePromise.listenerCallback,
                                                             voidPtr))
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
        let thread = currentThread()

        defer {

            nativeList.deinitialize(count: 1)
            nativeList.deallocate()

            promiseList.deinitialize(count: 1)
            promiseList.deallocate()
        }
        nativeList.pointee.size = Int32(promises.count)
        nativeList.pointee.elements = classes
        promiseList.pointee.list = nativeList.pointee

        let result = try ErrorCheck.nativeCall(thread, dxfg_Promises_allOf(thread, promiseList))
        return NativePromise(promise: result)
    }

    static func removeListener(listener: PromiseListener) {
        listeners.removeAll { listener in
            listener.value === listener
        }
    }
}
