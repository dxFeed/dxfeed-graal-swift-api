//
//  NativeSymbolParser.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 17.11.23.
//

import Foundation
@_implementationOnly import graal_api

class NativeSymbolParser {
    func parse(_ symbols: String) throws -> [String] {
        let thread = currentThread()
        let symbols = try ErrorCheck.nativeCall(thread, dxfg_Tools_parseSymbols(thread, symbols.toCStringRef()))
        var result = [String]()
        for index in 0..<Int(symbols.pointee.size) {
            result.append(String(pointee: symbols.pointee.elements[index]))
        }
        try ErrorCheck.nativeCall(thread, dxfg_CList_String_release(thread, symbols))
        return result
    }
}
