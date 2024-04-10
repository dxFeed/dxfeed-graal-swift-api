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

    static let listenerCallback: dxfg_observable_list_model_listener_function = {_, nativeEvents, context in
        if let context = context {
            var events = [MarketEvent]()
            let listener: AnyObject = bridge(ptr: context)
            if let listener =  listener as? WeakModel {
                guard let subscription = listener.value else {
                    return
                }
                let count = Int(nativeEvents?.pointee.size ?? 0)
                for index in 0..<count {
                    if let element = nativeEvents?.pointee.elements[index] {
                        if let event = try? subscription.mapper.fromNative(native: element) {
                            events.append(event)
                        }
                    }
                }
                ThreadManager.insertPthread()
                subscription.listener?.changed(order: events)
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

    func getEvents() throws -> [MarketEvent]? {
        return nil
    }

    func addListener(_ listener: ObservableListModelListener?) throws {

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
