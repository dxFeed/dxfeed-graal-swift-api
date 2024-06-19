//
//  ProfileIterator.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 01.09.23.
//

import Foundation

class ProfileIterator {
    private let native: NativeProfileIterator

    init(_ native: NativeProfileIterator) {
        self.native = native
    }

    func hasNext() throws -> Bool {
        try self.native.hasNext()
    }

    func next() throws -> InstrumentProfile {
        return try self.native.next()
    }
}
