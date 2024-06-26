//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation

infix operator >>> : BitwiseShiftPrecedence

extension Long {
    /// The unsigned right shift operator ">>>" shifts a zero into the leftmost position, while the leftmost position after ">>" depends on sign extension.
    static func >>> (lhs: Long, rhs: Long) -> Long {
        return Long(bitPattern: UInt64(bitPattern: lhs) >> UInt64(rhs))
    }
}
