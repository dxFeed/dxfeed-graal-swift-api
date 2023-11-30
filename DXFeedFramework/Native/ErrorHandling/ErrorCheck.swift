//
//  ErrorCheck.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 16.03.2023.
//

import Foundation
@_implementationOnly import graal_api

/// Utility class for check native calls.
/// The location of the imported functions is in the header files "dxfg_catch_exception.h".
class ErrorCheck {

    enum Result: Int32 {
        case success = 0
    }

    static func test() throws {
        let exception = GraalException.undefined
        throw exception
    }

    @discardableResult
    static func nativeCall(_ thread: OpaquePointer!, _ code: Int64) throws -> Int64 {
        if code < Result.success.rawValue {
            if let exception = fetchException(thread) {
                throw exception
            }
            return code
        } else {
            return code
        }
    }

    @discardableResult
    static func nativeCall(_ thread: OpaquePointer!, _ code: Int32) throws -> Int32 {
        if code < Result.success.rawValue {
            if let exception = fetchException(thread) {
                throw exception
            }
            return code
        } else {
            return code
        }
    }

    static func nativeCall<T>(_ thread: OpaquePointer!, _ result: T?) throws -> T {
        if let result = result {
            return result
        } else {
            if let exception = fetchException(thread) {
                throw exception
            } else {
                throw GraalException.fail(message: "Something went wrong. Graal exception is empty",
                                          className: "",
                                          stack: "")
            }
        }
    }

    static func graalCall(_ result: Int32) throws {
        let result = GraalErrorCode(rawValue: result)
        if result != .noError {
            throw GraalException.isolateFail(message: result?.description ?? "Couldn't get exception value")
        }
    }

    private static func fetchException(_ thread: OpaquePointer!) -> GraalException? {
        let exception = dxfg_get_and_clear_thread_exception_t(thread)
        if let pointee = exception?.pointee {
            let message = String(pointee: pointee.message, default: "Graall Exception")
            let className = String(pointee: pointee.className, default: "")
            let stackTrace = String(pointee: pointee.stackTrace, default: "")
            let gException =  GraalException.fail(message: message,
                                                  className: className,
                                                  stack: stackTrace)
            dxfg_Exception_release(thread, exception)
            return gException
        } else {
            return nil
        }
    }

}
