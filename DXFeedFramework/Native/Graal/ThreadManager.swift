//
//  ThreadManager.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 14.03.2023.
//

import Foundation
@_implementationOnly import graal_api

/// To execute a function in GraalVM, it is necessary to use a Graal thread.
///
/// This function is responsible for obtaining a new Graal thread or utilizing an existing one within the GraalVM environment.
/// It checks whether the current Graal thread is available; if it is, the function returns a reference to it.
/// If not, it creates a new thread and returns a reference to the newly created thread. This function is commonly used in the context of multi-threaded programming to manage and work with threads in GraalVM.
func currentThread() -> OpaquePointer! {
    let currentThread = graal_get_current_thread(Isolate.shared.isolate.pointee)
    if currentThread == nil {
        return ThreadManager.shared.attachThread().threadPointer.pointee
    } else {
        return currentThread
    }
}

/// This is a utility class that implements a thread-local variable using Thread.current.threadDictionary.
/// This variable is used to store a reference to an ISolateThread within a specific thread.
class ThreadManager {
    fileprivate static let shared = ThreadManager()
    private static let kThreadKey = "GraalThread"
    private init() {

    }
    fileprivate func attachThread() -> IsolateThread {
        defer {
            objc_sync_exit(self)
        }
        objc_sync_enter(self)
        if let thread = Thread.current.threadDictionary[ThreadManager.kThreadKey] as? IsolateThread {
            return thread
        } else {
            let thread = IsolateThread()
            Thread.current.threadDictionary[ThreadManager.kThreadKey] = thread
            return thread
        }
    }

}
