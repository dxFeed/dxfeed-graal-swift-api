//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
        return try String(nullable: result).value()
    }

}
