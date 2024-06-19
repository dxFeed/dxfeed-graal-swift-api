//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

/// Protocol for implement your custom symbol
///
/// Dervied from  this procol can be used with ``DXFeedSubcription`` to specify subscription

public protocol Symbol {
    /// Custom symbol has to return string representation.
    var stringValue: String { get }
}

extension Symbol {
    public var stringValue: String {
        fatalError("Symbol.stringValue has not been implemented")
    }
}
