//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
@_implementationOnly import graal_api

/// Represents an isolate (a JVM instance).
/// Contains a handle that is a pointer to the runtime data structure for the isolate.
/// 
/// This project intentionally uses only one isolate instance for the following reasons:
/// 
/// 
/// Old open issue on GitHub associated with a memory leak.
/// [Memory Leak on graal_isolatethread_t](https://github.com/oracle/graal/issues/3474)
///
/// 
/// There are no business cases associated with the creation of multiple isolates.
/// 
/// 
/// User error-prone logic when mixing multiple isolates.
/// 
/// 
/// Each native method is associated with a specific ``Isolate``,
/// and takes an ``IsolateThread`` as its first argument.
class Isolate {
    /// A singleton lazy-initialization instance of ``Isolate``.
    static let shared = Isolate()
    internal let isolate = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
    private let params = UnsafeMutablePointer<graal_create_isolate_params_t>.allocate(capacity: 1)
    private let thread = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
    let waiter = DispatchGroup()
    lazy var osThread = {
        let thread = Thread {
            do {
                try ErrorCheck.graalCall(graal_create_isolate(self.params, self.isolate, self.thread))
            } catch GraalException.fail(let message, let className, let stack) {
                let errorMessage = "!!!Isolate init failed: \(message) in \(className) with \(stack)"
                fatalError(errorMessage)
            } catch GraalException.isolateFail(let message) {
                let errorMessage = "!!!Isolate init failed: \(message)"
                fatalError(errorMessage)
            } catch GraalException.undefined {
                let errorMessage = "!!!Isolate init failed: undefined"
                fatalError(errorMessage)
            } catch {
                let errorMessage = "!!!Isolate init failed: Unexpected error \(error)"
                fatalError(errorMessage)
            }
            OrderSource.initAllValues()

            self.waiter.leave()
            Thread.sleep(forTimeInterval: .infinity)
        }
        thread.qualityOfService = .userInteractive
        return thread
    }()

    deinit {
        self.isolate.deallocate()
        self.params.deallocate()
        self.thread.deallocate()
    }

    /// Internal cleanup function.
    /// Just for testing purposes
    func cleanup() {
        if self.thread.pointee != nil {
            graal_detach_all_threads_and_tear_down_isolate(self.thread.pointee)
        }
    }

    /// Isolate should be initialized in main thread to avoid problem with overcommited queues.
    ///
    /// Problem with overcommited:
    ///
    /// It's important to note that if a user starts working with the SDK from the default queue,
    /// their tasks may be transferred to the overcommitted queue.
    /// Within the context of GraalVM, this transfer can result in the creation of a new thread, which might have already been attached to other tasks.
    /// This could lead to a fatalError, so it's crucial to carefully manage these processes and consider potential issues when working with the SDK."
    private init() {
#if DEBUG
    print("FEED SDK: Debug")
#else
    print("FEED SDK: Release")
#endif
        osThread.qualityOfService = .userInteractive
        waiter.enter()
        osThread.start()
        waiter.wait()
    }

    // only for testing
    func callGC() {
        let thread = currentThread()
        _ = try? ErrorCheck.nativeCall(thread, dxfg_gc(thread))
    }

    func throwException() throws {
        let thread = currentThread()
        // to init com.dxfeed.sdk.NativeUtils
        _ = try ErrorCheck.nativeCall(thread,
                                      dxfg_get_and_clear_thread_exception_t(thread))
        _ = try ErrorCheck.nativeCall(thread, dxfg_throw_exception(thread))
    }
}
