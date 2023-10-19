//
//  NativePublisher.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 13.10.23.
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
