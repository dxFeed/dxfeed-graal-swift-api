//
//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation

class DXObservableSubscription {
    /// Subscription native wrapper.
    private let native: NativeObservableSubscription
    /// List of event types associated with this ``DXObservableSubscription``
    fileprivate let types: [IEventType.Type]

    /// - Throws: ``GraalException`` Rethrows exception from Java, ``ArgumentException/argumentNil``
    internal init(native: NativeObservableSubscription?, events: [IEventType.Type]) throws {
        if let native = native {
            self.native = native
        } else {
            throw ArgumentException.argumentNil
        }
        self.types = events
    }
}

extension DXObservableSubscription: IObservableSubscription {
    public func isClosed() -> Bool {
        return native.isClosed()
    }

    public var eventTypes: [IEventType.Type] {
        return types
    }

    public func isContains(_ eventType: IEventType.Type) -> Bool {
        return types.contains { type in
            type == eventType
        }
    }

    /// - Throws: GraalException. Rethrows exception from Java.
    public func addChangeListener(_ listener: ObservableSubscriptionChangeListener) throws {
        try native.addChangeListener(listener)
    }

    /// - Throws: GraalException. Rethrows exception from Java.
    public func removeChangeListener(_ listener: ObservableSubscriptionChangeListener) throws {
        try native.removeChangeListener(listener)
    }
}
