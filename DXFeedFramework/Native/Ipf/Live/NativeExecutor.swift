//
//  NativeExecutor.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 31.08.23.
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
                                                 dxfg_ExecutorBaseOnConcurrentLinkedQueue_new(thread))
        return NativeExecutor(executor: executor)
    }

    static func createOnScheduledThreadPool(numberOfThreads: Int32, nameOfthread: String) throws -> NativeExecutor {
        let thread = currentThread()
        let executor = try ErrorCheck.nativeCall(thread,
                                                 dxfg_Executors_newScheduledThreadPool(thread,
                                                                                       numberOfThreads,
                                                                                       nameOfthread.toCStringRef()))
        return NativeExecutor(executor: executor)
    }

    static func createOnFixedThreadPool(numberOfThreads: Int32, nameOfthread: String) throws -> NativeExecutor {
        let thread = currentThread()
        let executor = try ErrorCheck.nativeCall(thread,
                                                 dxfg_Executors_newFixedThreadPool(thread,
                                                                                   numberOfThreads,
                                                                                   nameOfthread.toCStringRef()))
        return NativeExecutor(executor: executor)
    }
}
