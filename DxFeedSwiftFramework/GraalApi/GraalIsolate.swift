//
//  DxFEnvironment.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 14.03.2023.
//

import Foundation
@_implementationOnly import graal_api

class GraalIsolate {
    static let shared = GraalIsolate()
    internal let isolate = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
    private let params = UnsafeMutablePointer<graal_create_isolate_params_t>.allocate(capacity: 1)
    private let thread = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
    
    deinit {
        self.isolate.deallocate()
        self.params.deallocate()
        self.thread.deallocate()
    }
    
    func cleanup() {
        if self.thread.pointee != nil {
            graal_detach_all_threads_and_tear_down_isolate(self.thread.pointee);
        }
    }
    
    init() {
        let ret = graal_create_isolate(self.params, self.isolate, thread)
        if ret != 0 {
            print("error creating isolate")
            exit(0)
        }
    }
}
