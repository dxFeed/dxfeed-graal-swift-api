//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
/// Represents [wildcard] subscription to all events of the specific event type.
///
/// The ``all`` constant can be added to any ``DXFeedSubcription`` instance with ``DXFeedSubcription/addSymbols(_:)-32ill`` method
/// to the effect of subscribing to all possible event symbols. The corresponding subscription will start
/// receiving all published events of the corresponding types.
///
/// [Javadoc](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/osub/WildcardSymbol.html)
public class WildcardSymbol: Symbol {
    /// Symbol prefix that is reserved for wildcard subscriptions.
    /// Any subscription starting with "*" is ignored with the exception of  ``WildcardSymbol`` subscription.
    static let reservedPrefix = "*"
    private let symbol: String

    /// Represents [wildcard] subscription to all events of the specific event type.
    ///
    ///
    /// **Note**
    ///
    /// Wildcard subscription can create extremely high network and CPU load for certain kinds of
    /// high-frequency events like quotes. It requires a special arrangement on the side of upstream data provider and
    /// is disabled by default in upstream feed configuration.
    /// Make that sure you have adequate resources and understand the impact before using it.
    /// It can be used for low-frequency events only (like Forex quotes), because each instance
    /// of ``DXFeedSubcription`` processes events in a single thread
    /// and there is no provision to load-balance wildcard
    /// subscription amongst multiple threads.
    public static let all = WildcardSymbol(symbol: reservedPrefix)

    /// Initializes a new instance of the ``WildcardSymbol`` class.
    /// - Parameters:
    ///   - symbol: The wildcard symbol
    private init(symbol: String) {
        self.symbol = symbol
    }

    /// Custom symbol has to return string representation.
    public var stringValue: String {
        return symbol
    }
}

extension WildcardSymbol: Hashable {
    public static func == (lhs: WildcardSymbol, rhs: WildcardSymbol) -> Bool {
        return lhs.symbol == rhs.symbol
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.symbol)
    }
}
