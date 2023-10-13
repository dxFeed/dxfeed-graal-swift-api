//
//  NativeProfileIterator.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 31.08.23.
//

import Foundation
@_implementationOnly import graal_api

/// Native wrapper over the Java Iterator class.
/// The location of the imported functions is in the header files "dxfg_ipf.h".
class NativeProfileIterator {
    private let iterator: UnsafeMutablePointer<dxfg_iterable_ip_t>
    private let isDeallocatd: Bool
    let mapper = InstrumentProfileMapper()

    deinit {
        if isDeallocatd {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_JavaObjectHandler_release(thread, &(iterator.pointee.handler)))
        }
    }

    init(_ iterator: UnsafeMutablePointer<dxfg_iterable_ip_t>, isDeallocated: Bool) {
        self.isDeallocatd = isDeallocated
        self.iterator = iterator
    }

    func hasNext() throws -> Bool {
        let thread = currentThread()
        let result = try? ErrorCheck.nativeCall(thread, dxfg_Iterable_InstrumentProfile_hasNext(thread, iterator))
        return result != 0
    }

    func next() throws -> InstrumentProfile {
        let thread = currentThread()
        let result = try ErrorCheck.nativeCall(thread, dxfg_Iterable_InstrumentProfile_next(thread, iterator))

        let profile = mapper.fromNative(native: result)
        _ = try ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_release(thread, result))
        return profile
    }
}
