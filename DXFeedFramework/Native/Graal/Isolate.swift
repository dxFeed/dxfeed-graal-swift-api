//
//  Isolate.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 14.03.2023.
//

import Foundation
@_implementationOnly import graal_api

class Isolate {
    static let shared = Isolate()
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
            graal_detach_all_threads_and_tear_down_isolate(self.thread.pointee)
        }
    }

    init() {
        try? ErrorCheck.graalCall(graal_create_isolate(self.params, self.isolate, thread))
    }
}
