//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

/// Provides API for publishing of events to local or remote  ``DXFeed``
/// 
/// [Read it first Javadoc](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXPublisher.html)
public class DXPublisher {
    /// Feed native wrapper.
    private let native: NativePublisher

    deinit {
    }

    internal init(native: NativePublisher?) throws {
        if let native = native {
            self.native = native
        } else {
            throw ArgumentException.argumentNil
        }
    }

    /// Publishes events to the corresponding feed.
    ///
    /// If the ``DXEndpoint`` of this publisher has
    /// ``DXEndpoint/Role-swift.enum/publisher`` role and it is connected, the
    /// published events will be delivered to the remote endpoints. Local ``DXEndpoint/getFeed()`` will
    /// always receive published events.
    /// [Read it first Javadoc](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXPublisher.html#publishEvents-java.util.Collection-)
    /// - Parameters:
    ///   - events: The collection of events to publish.
    /// - Throws: GraalException. Rethrows exception from Java.recore
    public func publish(events: [MarketEvent]) throws {
        try native.publishEvents(events: events)
    }
}
