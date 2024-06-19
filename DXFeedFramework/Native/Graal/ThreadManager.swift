//
//  ThreadManager.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 14.03.2023.
//

import Foundation
@_implementationOnly import graal_api

func currentThread() -> OpaquePointer! {
    let currentThread = graal_get_current_thread(Isolate.shared.isolate.pointee)
    if currentThread == nil {
        return ThreadManager.shared.attachThread().threadPointer.pointee
    } else {
        return currentThread
    }
}

class ThreadManager {
    static let shared = ThreadManager()
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
