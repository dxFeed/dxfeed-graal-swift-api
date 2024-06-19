//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
@_implementationOnly import graal_api

/// Native wrapper over the Java com.dxfeed.api.DXFeed class.
/// The location of the imported functions is in the header files "dxfg_feed.h".
class NativeFeed {
    let feed: UnsafeMutablePointer<dxfg_feed_t>?
    private let mapper = EventMapper()

    deinit {
        if let feed = feed {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_JavaObjectHandler_release(thread, &(feed.pointee.handler)))
        }
    }
    init(feed: UnsafeMutablePointer<dxfg_feed_t>) {
        self.feed = feed
    }

    func createSubscription(_ types: [IEventType.Type]) throws -> NativeSubscription? {
        let nativeCodes = types.map { $0.type.nativeCode() }
        let elements = ListNative(elements: nativeCodes)
        let listPointer = elements.newList()
        defer {
            listPointer.deinitialize(count: 1)
            listPointer.deallocate()
        }

        let thread = currentThread()
        let subscription = try ErrorCheck.nativeCall(thread,
                                                     dxfg_DXFeed_createSubscription2(thread,
                                                                                     self.feed,
                                                                                     listPointer))
        return NativeSubscription(subscription: subscription)
    }

    func createSubscription(_ type: IEventType.Type) throws -> NativeSubscription? {
        let thread = currentThread()
        let subscription = try ErrorCheck.nativeCall(thread,
                                                     dxfg_DXFeed_createSubscription(thread,
                                                                                    self.feed,
                                                                                    type.type.nativeCode()))
        return NativeSubscription(subscription: subscription)
    }

    func createTimeSeriesSubscription(_ type: [IEventType.Type]) throws -> NativeTimeSeriesSubscription? {
        let nativeCodes = type.map { $0.type.nativeCode() }
        let elements = ListNative(elements: nativeCodes)
        let listPointer = elements.newList()
        defer {
            listPointer.deinitialize(count: 1)
            listPointer.deallocate()
        }

        let thread = currentThread()
        let subscription = try ErrorCheck.nativeCall(thread,
                                                     dxfg_DXFeed_createTimeSeriesSubscription2(
                                                        thread,
                                                        self.feed,
                                                        listPointer))
        return NativeTimeSeriesSubscription(native: subscription)
    }

    func createTimeSeriesSubscription(_ event: IEventType.Type) throws -> NativeTimeSeriesSubscription? {
        let thread = currentThread()
        let subscription = try ErrorCheck.nativeCall(thread,
                                                     dxfg_DXFeed_createTimeSeriesSubscription(
                                                        thread,
                                                        self.feed,
                                                        event.type.nativeCode()))
        return NativeTimeSeriesSubscription(native: subscription)
    }

    func getLastEvent(type: MarketEvent) throws -> ILastingEvent? {
        let thread = currentThread()
        let inputEvent = try ErrorCheck.nativeCall(thread,
                                                   dxfg_EventType_new(
                                                    thread,
                                                    type.eventSymbol,
                                                    type.type.nativeCode())
        )
        defer {
            _ = try? ErrorCheck.nativeCall(thread,
                                           dxfg_EventType_release(
                                            thread,
                                            inputEvent))
        }
        _ = try ErrorCheck.nativeCall(thread,
                                      dxfg_DXFeed_getLastEvent(
                                        thread,
                                        self.feed,
                                        inputEvent))

        let event = try mapper.fromNative(native: inputEvent)
        return event?.lastingEvent
    }

    func getLastEvents(types: [MarketEvent]) throws -> [ILastingEvent] {
        let listPointer = UnsafeMutablePointer<dxfg_event_type_list>.allocate(capacity: 1)
        listPointer.pointee.size = Int32(types.count)
        let classes = UnsafeMutablePointer<UnsafeMutablePointer<dxfg_event_type_t>?>
            .allocate(capacity: types.count)
        var iterator = classes
        let thread = currentThread()

        types.forEach { event in
            if let inputEvent = try? ErrorCheck.nativeCall(thread, dxfg_EventType_new(
                thread,
                event.eventSymbol,
                event.type.nativeCode())) {
                iterator.initialize(to: inputEvent)
                iterator = iterator.successor()
            }
        }
        listPointer.pointee.elements = classes

        defer {
            for index in 0..<Int(listPointer.pointee.size) {
                let element = listPointer.pointee.elements[index]
                _ = try? ErrorCheck.nativeCall(thread,
                                               dxfg_EventType_release(
                                                thread,
                                                element))
            }
            listPointer.deinitialize(count: 1)
            listPointer.deallocate()
        }
        var results = [ILastingEvent]()
        _ = try ErrorCheck.nativeCall(thread,
                                      dxfg_DXFeed_getLastEvents(
                                        thread,
                                        self.feed,
                                        listPointer))

        for index in 0..<Int(listPointer.pointee.size) {
            if let elemenent = listPointer.pointee.elements[index] {
                let event = try mapper.fromNative(native: elemenent)
                if let lastingEvent = event?.lastingEvent {
                    results.append(lastingEvent)
                }
            }
        }
        return results
    }
}
