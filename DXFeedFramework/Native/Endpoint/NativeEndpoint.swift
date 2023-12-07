//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
@_implementationOnly import graal_api

/// Native wrapper over the Java com.dxfeed.api.DXEndpoint class.
class NativeEndpoint {
    private class WeakListener: WeakBox<EndpointListener> { }
    private static let listeners = ConcurrentArray<WeakListener>()

    let endpoint: UnsafeMutablePointer<dxfg_endpoint_t>!
    var listener: UnsafeMutablePointer<dxfg_endpoint_state_change_listener_t>?

    private static let finalizeCallback: dxfg_finalize_function = { _, context in
        if let context = context {
            let endpoint: AnyObject = bridge(ptr: context)
            if let listener =  endpoint as? WeakListener {
                NativeEndpoint.listeners.removeAll(where: {
                    $0 === listener
                })
            }
        }
    }

    private static let listenerCallback: dxfg_endpoint_state_change_listener_func = {_, oldState, newState, context in
        if let context = context {
            let endpoint: AnyObject = bridge(ptr: context)
            if let listener =  endpoint as? WeakListener {
                var old = (try? EnumUtil.valueOf(value: DXEndpointState.convert(oldState))) ?? .notConnected
                var new = (try? EnumUtil.valueOf(value: DXEndpointState.convert(newState))) ?? .notConnected
                listener.value?.changeState(old: old, new: new)
            }
        }
    }

    private lazy var feed: NativeFeed? = {
        let thread = currentThread()
        do {
            let nativeFeed = try ErrorCheck.nativeCall(thread, dxfg_DXEndpoint_getFeed(thread, self.endpoint))
            return NativeFeed(feed: nativeFeed)
        } catch {
            return nil
        }
    }()

    private lazy var publisher: NativePublisher? = {
        let thread = currentThread()
        do {
            let nativeFeed = try ErrorCheck.nativeCall(thread, dxfg_DXEndpoint_getPublisher(thread, self.endpoint))
            return NativePublisher(publisher: nativeFeed)
        } catch {
            return nil
        }
    }()

    fileprivate func removeListener() {
        if let listener = listener {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread,
                                           dxfg_DXEndpoint_removeStateChangeListener(thread,
                                                                                     self.endpoint,
                                                                                     self.listener))
            _ = try? ErrorCheck.nativeCall(thread, dxfg_JavaObjectHandler_release(thread, &(listener.pointee.handler)))
            self.listener = nil
        }
    }

    deinit {
        try? close()
        removeListener()
        if let endpoint = self.endpoint {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread,
                                           dxfg_JavaObjectHandler_release(thread, &(endpoint.pointee.handler)))
        }
    }

    internal init(_ native: UnsafeMutablePointer<dxfg_endpoint_t>) {
        self.endpoint = native
    }

    func getNativeFeed() -> NativeFeed? {
        return self.feed
    }

    func getNativePublisher() -> NativePublisher? {
        return self.publisher
    }

    func addListener(_ listener: EndpointListener) throws {
        removeListener()
        let weakListener = WeakListener(value: listener)
        NativeEndpoint.listeners.append(newElement: weakListener)
        let voidPtr = bridge(obj: weakListener)
        let thread = currentThread()
        let listener = try ErrorCheck.nativeCall(thread,
                                                 dxfg_PropertyChangeListener_new(thread,
                                                                                 NativeEndpoint.listenerCallback,
                                                                                 voidPtr))
        self.listener = listener
        try ErrorCheck.nativeCall(thread, dxfg_Object_finalize(thread,
                                                               &(listener.pointee.handler),
                                                               NativeEndpoint.finalizeCallback,
                                                               voidPtr))
        try ErrorCheck.nativeCall(currentThread(),
                                  dxfg_DXEndpoint_addStateChangeListener(thread,
                                                                         endpoint,
                                                                         self.listener))
    }
    func connect(_ address: String) throws {
        let thread = currentThread()
        try ErrorCheck.nativeCall(thread, dxfg_DXEndpoint_connect(thread, self.endpoint, address.toCStringRef()))
    }
    func reconnect() throws {
        let thread = currentThread()
        try ErrorCheck.nativeCall(thread, dxfg_DXEndpoint_reconnect(thread, self.endpoint))
    }
    func disconnect() throws {
        let thread = currentThread()
        try ErrorCheck.nativeCall(thread, dxfg_DXEndpoint_disconnect(thread, self.endpoint))
    }
    func disconnectAndClear() throws {
        let thread = currentThread()
        try ErrorCheck.nativeCall(thread, dxfg_DXEndpoint_disconnectAndClear(thread, self.endpoint))
    }
    func close() throws {
        let thread = currentThread()
        try ErrorCheck.nativeCall(thread, dxfg_DXEndpoint_close(thread, self.endpoint))
    }
    func closeAndAWaitTermination() throws {
        let thread = currentThread()
        try ErrorCheck.nativeCall(thread, dxfg_DXEndpoint_closeAndAwaitTermination(thread, self.endpoint))
    }
    func set(password: String) throws {
        let thread = currentThread()
        try ErrorCheck.nativeCall(thread, dxfg_DXEndpoint_password(thread, self.endpoint, password.toCStringRef()))
    }

    func set(userName: String) throws {
        let thread = currentThread()
        try ErrorCheck.nativeCall(thread, dxfg_DXEndpoint_user(thread, self.endpoint, userName.toCStringRef()))
    }

    func awaitProcessed() throws {
        let thread = currentThread()
        try ErrorCheck.nativeCall(thread, dxfg_DXEndpoint_awaitProcessed(thread, self.endpoint))
    }

    func awaitNotConnected() throws {
        let thread = currentThread()
        try ErrorCheck.nativeCall(thread, dxfg_DXEndpoint_awaitNotConnected(thread, self.endpoint))
    }

    public func getState() throws -> DXEndpointState {
        let thread = currentThread()
        let value = try ErrorCheck.nativeCall(thread, dxfg_DXEndpoint_getState(thread, self.endpoint))
        return try EnumUtil.valueOf(value: DXEndpointState.convert(value))
    }
}
