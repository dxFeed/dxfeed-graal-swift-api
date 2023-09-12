//
//  ILastingEvent.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 17.08.23.
//

import Foundation
/// Represents up-to-date information about some
/// condition or state of an external entity that updates in real-time.
///
/// For example, a ``Quote`` is an up-to-date information about best bid and best offer for a specific symbol.
///
/// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/LastingEvent.html)
public protocol ILastingEvent: IEventType {
}
