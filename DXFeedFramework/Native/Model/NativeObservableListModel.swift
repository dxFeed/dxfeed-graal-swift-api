//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
@_implementationOnly import graal_api

class NativeObservableListModel {
    private class WeakModel: WeakBox<NativeObservableListModel> { }
    
    weak var listener: ObservableListModelListener?
    let native: UnsafeMutablePointer<dxfg_observable_list_model_t>?
    var nativeListener: UnsafeMutablePointer<dxfg_observable_list_model_listener_t>?
    private let mapper = EventMapper()

    private static let listeners = ConcurrentArray<WeakModel>()

    private static let finalizeCallback: dxfg_finalize_function = { _, context in
        if let context = context {
            let endpoint: AnyObject = bridge(ptr: context)
            if let listener =  endpoint as? WeakModel {
                NativeObservableListModel.listeners.removeAll(where: {
                    return $0 === listener
                })
            }
        }
    }

    private static let listenerCallback: dxfg_observable_list_model_listener_function = {_, nativeEvents, context in
        if let context = context {
            let listener: AnyObject = bridge(ptr: context)
            if let listener =  listener as? WeakModel {
                guard let subscription = listener.value else {
                    return
                }
                var events = [MarketEvent]()
                if let nativeEvents = nativeEvents {
                    events = subscription.convert(native: nativeEvents)
                }
                ThreadManager.insertPthread()
                subscription.listener?.changed(orders: events)
            }
        }
    }
    
    deinit {
        clearNativeListeners()

        if let native = native {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread,
                                           dxfg_JavaObjectHandler_release(thread,
                                                                          &(native.pointee.handler)))
        }
    }

    init(native: UnsafeMutablePointer<dxfg_observable_list_model_t>?) {
        self.native = native
    }
    
    fileprivate func convert(native: UnsafePointer<dxfg_event_type_list>) -> [MarketEvent] {
        var events = [MarketEvent]()
        let count = Int(native.pointee.size)
        for index in 0..<count {
            if let element = native.pointee.elements[index] {
                if let event = try? mapper.fromNative(native: element) {
                    events.append(event)
                }
            }
        }
        return events
    }

    func getEvents() throws -> [MarketEvent]? {
        let thread = currentThread()
        let nativeEvents = try ErrorCheck.nativeCall(thread, dxfg_ObservableListModel_toArray(thread, native))
        defer {
           _ = try? ErrorCheck.nativeCall(thread, dxfg_CList_EventType_release(thread, nativeEvents))
        }
        let events = convert(native: nativeEvents)
        return events
    }

    func addListener(_ listener: ObservableListModelListener?) throws {
        clearNativeListeners()
        self.listener = listener

        let weakModel = WeakModel(value: self)
        NativeObservableListModel.listeners.append(newElement: weakModel)
        let voidPtr = bridge(obj: weakModel)
        let thread = currentThread()
        let listener = try ErrorCheck.nativeCall(thread,
                                                 dxfg_ObservableListModelListener_new(
                                                    thread,
                                                    NativeObservableListModel.listenerCallback,
                                                    voidPtr))

        try ErrorCheck.nativeCall(thread, dxfg_Object_finalize(thread,
                                                               &(listener.pointee.handler),
                                                               NativeObservableListModel.finalizeCallback,
                                                               voidPtr))
        self.nativeListener = listener
        _ = try ErrorCheck.nativeCall(thread,
                                      dxfg_ObservableListModel_addListener(thread,
                                                                           native,
                                                                           self.nativeListener))
    }

    fileprivate func clearNativeListeners() {
        if let nativeListener = nativeListener {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread,
                                           dxfg_ObservableListModel_removeListener(thread,
                                                                                   native,
                                                                                   nativeListener))
            _ = try? ErrorCheck.nativeCall(thread,
                                           dxfg_JavaObjectHandler_release(thread,
                                                                          &(nativeListener.pointee.handler)))
        }
    }
}
