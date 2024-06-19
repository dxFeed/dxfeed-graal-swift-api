//
//  ErrorCheck.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 16.03.2023.
//

import Foundation
@_implementationOnly import graal_api

class ErrorCheck {
    static func test() throws {
        let exception = GraalException.undefined
        throw exception
    }
    
    static func nativeCall(_ code: Int32) throws -> Bool {
        if code < 0 {            
            try? fetchException()
            return false
        } else {
            return true
        }
        
    }
    
    static func nativeCall<T>(_ thread: IsolateThread, _ result: T?) -> T? {
        if result == nil {
            
        } else {
            
        }
        return result
    }
    
    static func graalCall(_ result: Int32) throws {
        let result = GraalErrorCode(rawValue: result)
        if result != .noError {
            try? fetchException()
        }
    }
    
    private static func fetchException() throws {
        let exception = dxfg_get_and_clear_thread_exception_t(ThreadManager.shared.attachThread().thread.pointee);
        if let pointee = exception?.pointee {
            let gException =  GraalException.fail(message: String.createString(pointer: exception?.pointee.message), className: String.createString(pointer: pointee.className), stack: String.createString(pointer: pointee.stackTrace))
            dxfg_Exception_release(ThreadManager.shared.attachThread().thread.pointee, exception);
            throw gException
        }
    }
    
}
