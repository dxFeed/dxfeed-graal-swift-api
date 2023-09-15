//
//  DXProfileIterator.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 01.09.23.
//

import Foundation

/// An iterator over a ``InstrumentProfile`` collection.
public class DXProfileIterator {
    private let native: NativeProfileIterator

    init(_ native: NativeProfileIterator) {
        self.native = native
    }

    /// Returns true if the iteration has more elements.
    /// (In other words, returns true if next would return an element rather than throwing an exception.)
    public func hasNext() throws -> Bool {
        try self.native.hasNext()
    }
    /// Returns the next element in the iteration.
    /// - Throws: GraalException. Rethrows exception from Java.
    public func next() throws -> InstrumentProfile {
        return try self.native.next()
    }
}
