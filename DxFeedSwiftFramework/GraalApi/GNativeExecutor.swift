//
//  GNativeExecutor.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 16.03.2023.
//

import Foundation
@_implementationOnly import graal_api

class GNativeExecutor {
    
    static func execute(_ block: () -> Int32) -> GStatusCode {
        if block() < 0 {
            let exception = dxfg_get_and_clear_thread_exception_t(GraalThreadManager.shared.attachThread().thread.pointee);
            var status: GStatusCode
            if let pointee = exception?.pointee {
                status = GStatusCode.fail(message: String.createString(pointer: exception?.pointee.message), className: String.createString(pointer: pointee.className), stack: String.createString(pointer: pointee.stackTrace))
                dxfg_Exception_release(GraalThreadManager.shared.attachThread().thread.pointee, exception);
            } else {
                status = .fail(message: "Error. Couldn't load exception from graal", className: "", stack: "")
            }
            return status
        } else {
            return .success
        }
    }
    
}
