//
//  NativeSubscription.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 30.05.23.
//

import Foundation
@_implementationOnly import graal_api

/// Native wrapper over the Java com.dxfeed.api.DxFeedSubscription class.
/// The location of the imported functions is in the header files "dxfg_subscription.h".
class NativeSubscription {
    class WeakSubscription: WeakBox<NativeSubscription> { }

    static let listeners = ConcurrentArray<WeakSubscription>()
    
    let subscription: UnsafeMutablePointer<dxfg_subscription_t>?
    var nativeListener: UnsafeMutablePointer<dxfg_feed_event_listener_t>?
    private let mapper = EventMapper()
    weak var listener: DXEventListener?

    private static let finalizeCallback: dxfg_finalize_function = { _, context in
        if let context = context {
            let endpoint: AnyObject = bridge(ptr: context)
            if let listener =  endpoint as? WeakSubscription {
                NativeSubscription.listeners.removeAll(where: {
                    return $0 === listener
                })
            }
        }
    }

    static let listenerCallback: dxfg_feed_event_listener_function = {_, nativeEvents, context in
        if let context = context {
            var events = [MarketEvent]()
            let listener: AnyObject = bridge(ptr: context)
            if let listener =  listener as? WeakSubscription {
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
                subscription.listener?.receiveEvents(events)
            }
        }
    }

    deinit {
        if let nativeListener = nativeListener {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread,
                                           dxfg_DXFeedSubscription_removeEventListener(thread,
                                                                                       subscription,
                                                                                       nativeListener))
            _ = try? ErrorCheck.nativeCall(thread,
                                           dxfg_JavaObjectHandler_release(thread,
                                                                          &(nativeListener.pointee.handler)))
        }
        if let subscription = subscription {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread,
                                           dxfg_JavaObjectHandler_release(thread,
                                                                          &(subscription.pointee.handler)))
        }
    }
    init(subscription: UnsafeMutablePointer<dxfg_subscription_t>?) {
        self.subscription = subscription
    }

    func addListener(_ listener: DXEventListener?) throws {
        if let nativeListener = nativeListener {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread,
                                           dxfg_DXFeedSubscription_removeEventListener(thread,
                                                                                       self.subscription,
                                                                                       nativeListener))
            _ = try? ErrorCheck.nativeCall(thread,
                                           dxfg_JavaObjectHandler_release(thread,
                                                                          &(nativeListener.pointee.handler)))
        }
        self.listener = listener

        let weakSubscription = WeakSubscription(value: self)
        NativeSubscription.listeners.append(newElement: weakSubscription)
        let voidPtr = bridge(obj: weakSubscription)
        let thread = currentThread()
        let listener = try ErrorCheck.nativeCall(thread,
                                                 dxfg_DXFeedEventListener_new(thread,
                                                                              NativeSubscription.listenerCallback,
                                                                              voidPtr))

        try ErrorCheck.nativeCall(thread, dxfg_Object_finalize(thread,
                                                               &(listener.pointee.handler),
                                                               NativeSubscription.finalizeCallback,
                                                               voidPtr))
        self.nativeListener = listener
        _ = try ErrorCheck.nativeCall(thread,
                                      dxfg_DXFeedSubscription_addEventListener(thread,
                                                                               subscription,
                                                                               self.nativeListener))
    }

    func addSymbols(_ symbol: Symbol) throws {
        let converted = SymbolMapper.newNative(symbol)
          defer {
            if let converted = converted {
                SymbolMapper.clearNative(symbol: converted)
            }
        }
        let thread = currentThread()
        _ = try ErrorCheck.nativeCall(thread, dxfg_DXFeedSubscription_addSymbol(thread, self.subscription, converted))
    }

    func addSymbols(_ symbols: [Symbol]) throws {
        let nativeSymbols = symbols.compactMap { SymbolMapper.newNative($0) }
        let elements = ListNative(pointers: nativeSymbols)
        let listPointer = elements.newList()
        defer {
            listPointer.deinitialize(count: 1)
            listPointer.deallocate()
            nativeSymbols.forEach { SymbolMapper.clearNative(symbol: $0) }
        }
        let thread = currentThread()
        _ = try ErrorCheck.nativeCall(thread,
                                      dxfg_DXFeedSubscription_addSymbols(thread,
                                                                         self.subscription,
                                                                         listPointer))
    }

    func removeSymbols(_ symbols: [Symbol]) throws {
        let nativeSymbols = symbols.compactMap { SymbolMapper.newNative($0) }
        let elements = ListNative(pointers: nativeSymbols)
        let listPointer = elements.newList()
        defer {
            listPointer.deinitialize(count: 1)
            listPointer.deallocate()
            nativeSymbols.forEach { SymbolMapper.clearNative(symbol: $0) }
        }
        let thread = currentThread()
        _ = try ErrorCheck.nativeCall(thread,
                                      dxfg_DXFeedSubscription_removeSymbols(thread,
                                                                            self.subscription,
                                                                            listPointer))

    }

    func isClosed() -> Bool {
        let thread = currentThread()
        let success = try? ErrorCheck.nativeCall(thread, dxfg_DXFeedSubscription_isClosed(thread, self.subscription))
        guard let success = success else {
            return true
        }
        return success != 0
    }
}
