//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation

public extension Dictionary {
    @inlinable public mutating func removeIf(condition: (Self.Element) -> Bool) {
        for (key, _) in filter(condition) { removeValue(forKey: key) }
    }
}

public extension NSMutableOrderedSet {
    func removeIf(using: NSPredicate) -> Bool {
        var changed = false
        for (value) in filtered(using: using) {
            remove(value)
            changed = true
        }
        return changed
    }
}
