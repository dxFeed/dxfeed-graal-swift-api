//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
@_implementationOnly import graal_api

class NativeSymbolParser {
    func parse(_ symbols: String) throws -> [String] {
        let thread = currentThread()
        let symbols = try ErrorCheck.nativeCall(thread, dxfg_Tools_parseSymbols(thread, symbols.toCStringRef())).value()
        var result = [String]()
        for index in 0..<Int(symbols.pointee.size) {
            result.append(String(pointee: symbols.pointee.elements[index]))
        }
        try ErrorCheck.nativeCall(thread, dxfg_CList_String_release(thread, symbols))
        return result
    }
}
