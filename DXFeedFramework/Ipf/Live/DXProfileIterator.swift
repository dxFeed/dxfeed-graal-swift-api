//
//  DXProfileIterator.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 01.09.23.
//

import Foundation

public class DXProfileIterator {
    private let native: NativeProfileIterator

    init(_ native: NativeProfileIterator) {
        self.native = native
    }

    public func hasNext() throws -> Bool {
        try self.native.hasNext()
    }

    public func next() throws -> InstrumentProfile {
        return try self.native.next()
    }
}
