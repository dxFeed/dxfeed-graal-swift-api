//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

public class SymbolParser {
    /// It returs list of symbols.
    ///
    /// You can use input like this
    /// "ipf[https://demo:demo@tools.dxfeed.com/ipf?TYPE=STOCK&compression=zip],APPL"
    ///  It will download symbols from ipf endpoint.
    /// - Throws: GraalException. Rethrows exception from Java.
    public static func parse(_ symbols: String) throws -> [String] {
        let nativeParser = NativeSymbolParser()
        return try nativeParser.parse(symbols)
    }
}
