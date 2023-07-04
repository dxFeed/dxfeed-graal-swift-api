//
//  ThreadManager.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 14.03.2023.
//

import Foundation

func currentThread() -> OpaquePointer! {
    ThreadManager.shared.attachThread().threadPointer.pointee
}

class ThreadManager {
    static let shared = ThreadManager()
    private static let kThreadKey = "GraalThread"
    private init() {

    }
    func attachThread() -> IsolateThread {
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
