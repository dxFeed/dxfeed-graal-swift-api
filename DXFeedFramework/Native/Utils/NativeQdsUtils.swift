//
//  NativeQdsUtils.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 05.12.23.
//

import Foundation
@_implementationOnly import graal_api

class NativeQdsUtils {
    static func execute(_ parameters: [String]) throws {
        let thread = currentThread()
        let cStrings = parameters.map { str in
            str.toCStringRef() as UnsafePointer<CChar>
        }
        let classes = UnsafeMutablePointer<UnsafePointer<CChar>?>
            .allocate(capacity: parameters.count)
        var iterator = classes
        for code in parameters {
            iterator.initialize(to: code.toCStringRef())
            iterator = iterator.successor()
        }

        let list = UnsafeMutablePointer<dxfg_string_list>.allocate(capacity: 1)
        list.pointee.size = Int32(parameters.count)
        list.pointee.elements = classes
        _ = try ErrorCheck.nativeCall(thread, dxfg_Tools_main(thread, list))

        classes.deinitialize(count: parameters.count)
        classes.deallocate()
        list.deinitialize(count: 1)
        list.deallocate()
    }
}
