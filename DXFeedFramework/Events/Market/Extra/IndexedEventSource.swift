//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
/// Source identifier for ``IIndexedEvent``.
///
/// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/IndexedEventSource.html)
public class IndexedEventSource {
    /// Gets a source identifier. Source identifier is non-negative.
    public let identifier: Int
    /// Gets a name of identifier.
    public let name: String

    /// The default source with zero identifier for all events that do not support multiple sources.
    public static let defaultSource =  IndexedEventSource( 0, "DEFAULT")

    /// Initializes a new instance of the ``IndexedEventSource`` class.
    ///
    /// - Parameters:
    ///     - identifier: The identifier
    ///     - name: The name of identifier
    public init(_ identifier: Int, _ name: String) {
        self.name = name
        self.identifier = identifier
    }
    /// Returns a string representation of the object.
    ///
    /// - Returns: A string representation of the object.
    public func toString() -> String {
        return name
    }
}

extension IndexedEventSource: Equatable {
    public static func == (lhs: IndexedEventSource, rhs: IndexedEventSource) -> Bool {
        return lhs === rhs || lhs.identifier == rhs.identifier
    }
}
