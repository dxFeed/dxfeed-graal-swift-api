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
    let mapper = InstrumentProfileMapper()

    deinit {
    }

    init(_ iterator: UnsafeMutablePointer<dxfg_iterable_ip_t>) {
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
