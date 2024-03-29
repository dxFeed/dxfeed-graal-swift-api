//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
        return ThreadManager.shared.attachThread().pointee
    } else {
        return currentThread
    }
}

/// This is a utility class that implements a thread-local variable using Thread.current.threadDictionary.
/// This variable is used to store a reference to an ISolateThread within a specific thread.
class ThreadManager {
    fileprivate static let shared = ThreadManager()
    private static let kThreadKey = "GraalThread"
    private static let key = UnsafeMutablePointer<pthread_key_t>.allocate(capacity: 1)
    static var str1: String = ""

    private init() {
        pthread_key_create(ThreadManager.key) { pointer in
            pointer.withMemoryRebound(to: OpaquePointer.self, capacity: 1) { _ in
                // The call to this method has been removed.
                // In some cases: an attachment to a java stream crashes when you try to use this stream (deinit in this java stream)
//                graal_detach_thread(pointer1.pointee)
                pointer.deallocate()
            }
        }
    }

    fileprivate func attachThread() -> UnsafeMutablePointer<OpaquePointer?> {
        defer {
            objc_sync_exit(self)
        }
        objc_sync_enter(self)
        let threadPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        _ = graal_attach_thread(Isolate.shared.isolate.pointee, threadPointer)
        _ = pthread_setspecific(ThreadManager.key.pointee, threadPointer)
        return threadPointer
    }

}

internal extension Thread {
    var threadName: String {
        if let currentOperationQueue = OperationQueue.current?.name {
            return "OperationQueue: \(currentOperationQueue)"
        } else if let underlyingDispatchQueue = OperationQueue.current?.underlyingQueue?.label {
            return "DispatchQueue: \(underlyingDispatchQueue)"
        } else {
            let name = __dispatch_queue_get_label(nil)
            return String(cString: name, encoding: .utf8) ?? Thread.current.description
        }
    }
}
