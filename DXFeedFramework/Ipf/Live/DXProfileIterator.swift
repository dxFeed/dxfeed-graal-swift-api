//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public func next() throws -> InstrumentProfile {
        return try self.native.next()
    }
}
