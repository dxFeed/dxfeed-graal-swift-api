//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation
@_implementationOnly import graal_api

internal extension GraalException {
    static func createNew(native: UnsafeMutablePointer<dxfg_exception_t>) -> GraalException {
        let pointee = native.pointee
        let message = String(pointee: pointee.message, default: "Graall Exception")
        let className = String(pointee: pointee.class_name, default: "")
        let stackTrace = String(pointee: pointee.print_stack_trace, default: "")
        let gException =  GraalException.fail(message: message,
                                              className: className,
                                              stack: stackTrace)
        return gException
    }

    func toNative() -> UnsafeMutablePointer<dxfg_exception_t>? {
        switch self {
        case .fail(message: let message, className: let className, stack: let stack):
            let exception = UnsafeMutablePointer<dxfg_exception_t>.allocate(capacity: 1)
            var pointee = exception.pointee
            pointee.class_name = className.toCStringRef()
            pointee.message = message.toCStringRef()
            pointee.print_stack_trace = stack.toCStringRef()
            exception.pointee = pointee
            return exception
        default:
            return nil
        }
    }
}
