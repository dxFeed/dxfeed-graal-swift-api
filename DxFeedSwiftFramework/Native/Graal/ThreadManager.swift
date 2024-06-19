//
//  ThreadManager.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 14.03.2023.
//

import Foundation

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
        var thread = Thread.current.threadDictionary[ThreadManager.kThreadKey]
        if thread == nil {
            thread = IsolateThread()
            Thread.current.threadDictionary[ThreadManager.kThreadKey] = thread
        }
        return thread as! IsolateThread
    }
}
