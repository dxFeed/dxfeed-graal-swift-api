//
//  GraalThreadHandler.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 14.03.2023.
//

import Foundation
@_implementationOnly import graal_api

class GraalThreadKeeper {
    let thread = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
    weak var th: Thread?
    
    deinit {
        assert(th == Thread.current, "Try \(String(describing: self)).\(#function) from non-parented thread. Check if an object reference is being passed to a thread other than the parent")
        if thread.pointee != nil {
            graal_detach_thread(self.thread.pointee)
            thread.deallocate()
        }
    }
    
    init() {
        th = Thread.current
        graal_attach_thread(GraalIsolate.shared.isolate.pointee, self.thread)
    }
}
