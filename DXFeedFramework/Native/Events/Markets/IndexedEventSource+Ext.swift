//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation
@_implementationOnly import graal_api

extension IndexedEventSource {
    func toNative() -> UnsafeMutablePointer<dxfg_indexed_event_source_t>? {
        let nativeSource = UnsafeMutablePointer<dxfg_indexed_event_source_t>.allocate(capacity: 1)
        nativeSource.pointee.id = Int32(identifier)
        nativeSource.pointee.name = name.toCStringRef()
        switch self {
        case _ as OrderSource:
            nativeSource.pointee.type = ORDER_SOURCE
        default:
            nativeSource.pointee.type = INDEXED_EVENT_SOURCE
        }
        return nativeSource
    }

    static func fromNative(native: UnsafeMutablePointer<dxfg_indexed_event_source_t>) -> IndexedEventSource {
        switch native.pointee.type {
        case ORDER_SOURCE:
            let identifier = native.pointee.id
            let sourceName = String(pointee: native.pointee.name)
            if let source = try? OrderSource.valueOf(identifier: Int(identifier)) {
                return source
            } else if let source = try? OrderSource.valueOf(name: sourceName) {
                return source
            } else {
                fatalError("Incorrect value of source \(native.pointee.id) \(sourceName)")
            }
        case INDEXED_EVENT_SOURCE:
            return IndexedEventSource(Int(native.pointee.id), String(pointee: native.pointee.name))
        default:
            fatalError("Incorrect value of source \(native.pointee.type)")
        }
    }
}
