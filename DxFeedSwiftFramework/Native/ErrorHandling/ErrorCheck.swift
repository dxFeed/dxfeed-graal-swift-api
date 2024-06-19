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
    
    @discardableResult
    static func nativeCall(_ thread: IsolateThread, _ code: Int32) throws -> Int32 {
        if code < 0 {            
            throw fetchException(thread)
        } else {
            return code
        }
        
    }
    
    static func nativeCall<T>(_ thread: IsolateThread, _ result: T?) throws -> T {
        if let result = result {
            return result
        } else {
            throw fetchException(thread)
        }
    }
    
    static func graalCall(_ result: Int32) throws {
        let result = GraalErrorCode(rawValue: result)
        if result != .noError {
            throw GraalException.isolateFail(message: result?.description ?? "Couldn't get exception value")
        }
    }
    
    private static func fetchException(_ thread: IsolateThread) -> GraalException {
        let exception = dxfg_get_and_clear_thread_exception_t(thread.thread.pointee);
        if let pointee = exception?.pointee {
            let gException =  GraalException.fail(message: String(utf8String: pointee.message) ?? "Empty graall exception", className: String(utf8String: pointee.className) ?? "", stack: String(utf8String: pointee.stackTrace) ?? "")
            dxfg_Exception_release(thread.thread.pointee, exception);
            return gException            
        } else {
            return GraalException.fail(message: "Something went wrong. Graal exception is empty", className: "", stack: "")
        }
        
    }
    
}
