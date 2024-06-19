//
//  SymbolParser.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 17.11.23.
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
