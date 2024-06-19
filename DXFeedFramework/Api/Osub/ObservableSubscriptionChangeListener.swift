//
//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation

/// The listener interface for receiving notifications on the changes of observed subscription.
/// All methods on this interface are invoked while holding a lock on ``IObservableSubscription`` instance,
/// thus all changes for a given subscription are synchronized with respect to each other.
///
/// Decorated symbols
/// The sets of symbols that are passed to ``symbolsAdded(symbols:)`` and ``symbolsRemoved(symbols:)``
/// are decorated depending on the actual implementation class of ``DXFeedSubscription``.
/// ``DXFeedTimeSeriesSubscription`` decorates original subscription symbols by wrapping them
/// into instances of ``TimeSeriesSubscriptionSymbol`` class.
///
/// Equality of symbols and notifications
///
/// Symbols are compared using their equals method. When one symbol in subscription is
/// replaced by the other one that is equal to it, then the decision of whether to issue
/// ``symbolsAdded(symbols:)`` notification is up to implementation.
///
/// However, the implementation that is returned by
/// ``DXPublisher/getSubscription(_:)`` can generate repeated
/// ``ObservableSubscriptionChangeListener/symbolsAdded(symbols:)`` notifications to
/// its listeners for the same symbols without the corresponding
/// ``ObservableSubscriptionChangeListener/symbolsRemoved(symbols:)``
/// notifications in between them. It happens when subscription disappears, cached data is lost, and subscription
/// reappears again. On each ``ObservableSubscriptionChangeListener/symbolsAdded(symbols:)``
/// notification data provider shall ``DXPublisher/publish(events:)`` the most recent events for
/// the corresponding symbols.
///
/// Wildcard symbols
///
/// The set of symbols may contain ``WildcardSymbol/all`` object.
/// See ``WildcardSymbol`` for details.
public protocol ObservableSubscriptionChangeListener: AnyObject {
    /// Invoked after a collection of symbols is added to a subscription.
    /// Subscription's set of symbols already includes added symbols when this method is invoked.
    /// The set of symbols is decorated.
    func symbolsAdded(symbols: Set<AnyHashable>)

    /// Invoked after a collection of symbols is removed from a subscription.
    /// Subscription's set of symbols already excludes removed symbols when this method is invoked.
    /// The set of symbols is decorated.
    /// Default implementation is empty.
    func symbolsRemoved(symbols: Set<AnyHashable>)

    /// Invoked after subscription is closed or when this listener is
    /// ``DXFeedSubcription/removeChangeListener(_:)`` from the subscription.
    /// ``DXPublisher`` ``DXPublisher/getSubscription(_:)`` is considered to be closed
    /// when the corresponding ``DXEndpoint`` is ``DXEndpoint/close()``.
    /// Default implementation is empty.
    func subscriptionClosed()
}
