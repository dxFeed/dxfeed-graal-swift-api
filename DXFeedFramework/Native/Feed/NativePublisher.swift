//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
@_implementationOnly import graal_api

/// Native wrapper over the Java com.dxfeed.api.DXPublisher class.
/// The location of the imported functions is in the header files "dxfg_feed.h".
class NativePublisher {
    let publisher: UnsafeMutablePointer<dxfg_publisher_t>?
    private let mapper = EventMapper()

    deinit {
        if let publisher = publisher {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_JavaObjectHandler_release(thread, &(publisher.pointee.handler)))
        }
    }

    init(publisher: UnsafeMutablePointer<dxfg_publisher_t>) {
        self.publisher = publisher
    }

    func publishEvents(events: [MarketEvent]) throws {
        try autoreleasepool {
            let nativeEvents = events.compactMap { event in
                try? mapper.toNative(event: event)
            }

            let nativePointers = ListNative(pointers: nativeEvents)
            let listPointer = nativePointers.newList()

            defer {
                listPointer.deinitialize(count: 1)
                listPointer.deallocate()
                nativeEvents.forEach { mapper.releaseNative(native: $0) }
            }
            let thread = currentThread()
            _ = try ErrorCheck.nativeCall(thread, dxfg_DXPublisher_publishEvents(thread,
                                                                                 publisher,
                                                                                 listPointer))        
        }
    }

    func createSubscription(_ type: IEventType.Type) throws -> NativeObservableSubscription? {
        let thread = currentThread()
        let subscription = try ErrorCheck.nativeCall(thread,
                                                     dxfg_DXPublisher_getSubscription(thread,
                                                                                      self.publisher,
                                                                                      type.type.nativeCode()))
        return NativeObservableSubscription(subscription: subscription)
    }
}
