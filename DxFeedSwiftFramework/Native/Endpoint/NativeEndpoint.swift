//
//  NativeEndpoint.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 22.05.23.
//

import Foundation
@_implementationOnly import graal_api

class NativeEndpoint {
    let endpoint: UnsafeMutablePointer<dxfg_endpoint_t>!
    var listener: UnsafeMutablePointer<dxfg_endpoint_state_change_listener_t>?
    static let storage = AtomicStorage<WeakListener>()
    static let finalizeCallback: dxfg_finalize_function = { _, context in
        if let context = context {
            let endpoint: AnyObject = bridge(ptr: context)
            if let listener =  endpoint as? WeakListener {
                NativeEndpoint.storage.remove(listener)
            }
        }
    }

    static let listenerCallback: dxfg_endpoint_state_change_listener_func = {_, oldState, newState, context in
        if let context = context {
            let endpoint: AnyObject = bridge(ptr: context)
            if let listener =  endpoint as? WeakListener {
                var old = (try? EndpointState.convert(oldState)) ?? .notConnected
                var new = (try? EndpointState.convert(newState)) ?? .notConnected
                listener.changeState(old: old, new: new)
            }
        }
    }

    private lazy var feed: NativeFeed? = {
        let thread = currentThread()
        do {
            let nativeFeed = try ErrorCheck.nativeCall(thread, dxfg_DXEndpoint_getFeed(thread, self.endpoint))
            return NativeFeed(feed: nativeFeed)
        } catch {
            print(error)
            return nil
        }
    }()
    deinit {
        if let listener = listener {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread, dxfg_JavaObjectHandler_release(thread, &(listener.pointee.handler)))
        }
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
    func addListener(_ listener: EndpointListener) throws {
        let weakListener = WeakListener(value: listener)
        NativeEndpoint.storage.append(weakListener)
        let voidPtr = bridge(obj: weakListener)
        let thread = currentThread()
        self.listener = try ErrorCheck.nativeCall(thread,
                                                  dxfg_PropertyChangeListener_new(thread,
                                                                                  NativeEndpoint.listenerCallback,
                                                                                  voidPtr))
        try ErrorCheck.nativeCall(currentThread(),
                                  dxfg_DXEndpoint_addStateChangeListener(thread,
                                                                         endpoint,
                                                                         self.listener,
                                                                         NativeEndpoint.finalizeCallback,
                                                                         voidPtr))
    }
    func connect(_ address: String) throws {
        let thread = currentThread()
        try ErrorCheck.nativeCall(thread, dxfg_DXEndpoint_connect(thread, self.endpoint, address.toCStringRef()))
    }
    func disconnect() throws {
        let thread = currentThread()
        try ErrorCheck.nativeCall(thread, dxfg_DXEndpoint_disconnect(thread, self.endpoint))
    }
}
