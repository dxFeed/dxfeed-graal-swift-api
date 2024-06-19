//
//  GraalThreadManager.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 14.03.2023.
//

import Foundation

class GraalThreadManager {
    static let shared = GraalThreadManager()
    private static let kThreadKey = "GraalThread"
    private init() {
        
    }
    func attachThread() -> GraalThreadKeeper {
        defer {
            objc_sync_exit(self)
        }
        objc_sync_enter(self)        
        var thread = Thread.current.threadDictionary[GraalThreadManager.kThreadKey]
        if thread == nil {
            thread = GraalThreadKeeper()
            Thread.current.threadDictionary[GraalThreadManager.kThreadKey] = thread
        }
        return thread as! GraalThreadKeeper
    }
}
