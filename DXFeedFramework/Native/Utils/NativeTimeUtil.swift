//
//  NativeTimeUtil.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 20.11.23.
//

import Foundation
@_implementationOnly import graal_api

class NativeTimeUtil {

    static func parse(timeFormat: NativeTimeFormat, value: String) throws -> Long {
        let thread = currentThread()
        let result = try ErrorCheck.nativeCall(thread,
                                               dxfg_TimeFormat_parse(thread,
                                                                     timeFormat.native,
                                                                     value.toCStringRef()))
        return result
    }

    static func format(timeFormat: NativeTimeFormat, value: Long) throws -> String {
        let thread = currentThread()
        let result = try ErrorCheck.nativeCall(thread,
                                               dxfg_TimeFormat_format(thread,
                                                                      timeFormat.native,
                                                                      value))
        return String(pointee: result)
    }

}
