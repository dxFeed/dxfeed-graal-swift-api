//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
@_implementationOnly import graal_api

/// Native wrapper over the Java Executor class.
/// The location of the imported functions is in the header files "dxfg_ipf.h".
class NativeExecutor {
    let executor: UnsafeMutablePointer<dxfg_executor_t>

    deinit {
        let thread = currentThread()
        _ = try? ErrorCheck.nativeCall(thread,
                                       dxfg_JavaObjectHandler_release(thread,
                                                                      &(executor.pointee.handler)))
    }

    internal init(executor: UnsafeMutablePointer<dxfg_executor_t>) {
        self.executor = executor
    }

    static func createOnConcurrentLinkedQueue() throws -> NativeExecutor {
        let thread = currentThread()
        let executor = try ErrorCheck.nativeCall(thread,
                                                 dxfg_ExecutorBaseOnConcurrentLinkedQueue_new(thread)).value()
        return NativeExecutor(executor: executor)
    }

    static func createOnScheduledThreadPool(numberOfThreads: Int32, nameOfthread: String) throws -> NativeExecutor {
        let thread = currentThread()
        let executor = try ErrorCheck.nativeCall(thread,
                                                 dxfg_Executors_newScheduledThreadPool(thread,
                                                                                       numberOfThreads,
                                                                                       nameOfthread.toCStringRef())).value()
        return NativeExecutor(executor: executor)
    }

    static func createOnFixedThreadPool(numberOfThreads: Int32, nameOfthread: String) throws -> NativeExecutor {
        let thread = currentThread()
        let executor = try ErrorCheck.nativeCall(thread,
                                                 dxfg_Executors_newFixedThreadPool(thread,
                                                                                   numberOfThreads,
                                                                                   nameOfthread.toCStringRef())).value()
        return NativeExecutor(executor: executor)
    }
}
