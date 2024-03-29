//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

/// Represents an indexed collection of up-to-date information about some
/// condition or state of an external entity that updates in real-time.
///
/// For example, ``Order`` represents an order to buy or to sell some market instrument
/// that is currently active on a market exchange and multiple
/// orders are active for each symbol at any given moment in time.
///
/// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/IndexedEvent.html)
public protocol IIndexedEvent: IEventType {
    /// Indicates a pending transactional update. When  is 1,
    /// it means that an ongoing transaction update, that spans multiple events, is in process.
    static var txPending: Int32 { get }
    /// Indicates that the event with the corresponding index has to be removed.
    static var removeEvent: Int32 { get }
    /// Indicates when the loading of a snapshot starts.
    static var snapshotBegin: Int32 { get }
    /// snapshotEnd or snapshotSnipindicates the end of a snapshot.
    /// The difference between snapshotEnd and snapshotSnip is the following:
    /// snapshotEndindicates that the data source sent all the data pertaining to
    /// the subscription for the corresponding indexed event,
    /// while snapshotSnipindicates that some limit on the amount of data was reached
    /// and while there still might be more data available, it will not be provided.
    static var snapshotEnd: Int32 { get }
    /// snapshotEnd or snapshotSnipindicates the end of a snapshot.
    /// The difference between snapshotEnd and snapshotSnipis the following:
    /// snapshotEndindicates that the data source sent all the data pertaining to
    /// the subscription for the corresponding indexed event,
    /// while snapshotSnipindicates that some limit on the amount of data was reached
    /// and while there still might be more data available, it will not be provided.
    static var snapshotSnip: Int32 { get }
    /// Is used to instruct dxFeed to use snapshot mode.
    /// It is intended to be used only for publishing to activate (if not yet activated) snapshot mode.
    /// The difference from snapshotBegin flag is that snapShotMode
    /// only switches on snapshot mode without starting snapshot synchronization protocol.
    static var snapShotMode: Int32 { get }

    /// Gets source of this event.
    var eventSource: IndexedEventSource { get }
    /// Gets or sets transactional event flags.
    var eventFlags: Int32 { get set }
    /// Gets or sets unique per-symbol index of this event.
    var index: Long { get }
}

/// Just wrapper around event flags.
///
/// To simplify checking in clientside code
public extension IIndexedEvent {
    func snapshotBegin() -> Bool {
        return (eventFlags & Self.snapshotBegin) != 0
    }

    func endOrSnap() -> Bool {
        return (self.eventFlags & (Self.snapshotEnd | Self.snapshotSnip)) != 0
    }

    func pending() -> Bool {
        return (self.eventFlags & Self.txPending) != 0
    }

    func isRemove() -> Bool {
        return (self.eventFlags & Self.removeEvent) != 0
    }

}
