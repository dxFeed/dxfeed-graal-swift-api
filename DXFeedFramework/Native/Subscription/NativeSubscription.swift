//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
@_implementationOnly import graal_api

/// Native wrapper over the Java com.dxfeed.api.DxFeedSubscription class.
/// The location of the imported functions is in the header files "dxfg_subscription.h".
class NativeSubscription {
    private class WeakSubscription: WeakBox<NativeSubscription> { }
    private class WeakSubscriptionChangeListener: WeakBox<NativeSubscription> { }

    private static let listeners = ConcurrentArray<WeakSubscription>()

    let subscription: UnsafeMutablePointer<dxfg_subscription_t>?
    var nativeListener: UnsafeMutablePointer<dxfg_feed_event_listener_t>?
    var nativeSubscriptionChangeListener: UnsafeMutablePointer<dxfg_observable_subscription_change_listener_t>?
    private var subscriptionListener: WeakSubscriptionChangeListener?

    private let mapper = EventMapper()
    weak var listener: DXEventListener?
    weak var subscriptionChangeListener: ObservableSubscriptionChangeListener?

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
                ThreadManager.insertPthread()
                subscription.listener?.receiveEvents(events)
            }
        }
    }

    static let symbolsAddedCallback:
    dxfg_ObservableSubscriptionChangeListener_function_symbolsAdded = { _, symbols, context in
        if let context = context {
            let listener: AnyObject = bridge(ptr: context)
            if let listener = listener as? WeakSubscriptionChangeListener {
                if let symbols = symbols {
                    let result = SymbolMapper.newSymbols(symbols: symbols)
                    listener.value?.subscriptionChangeListener?.symbolsAdded(symbols: Set(result))
                }
            }
        }
    }

    static let symbolsRemovedCallback: dxfg_ObservableSubscriptionChangeListener_function_symbolsRemoved
    = { _, symbols, context in
        if let context = context {
            let listener: AnyObject = bridge(ptr: context)
            if let listener = listener as? WeakSubscriptionChangeListener {
                if let symbols = symbols {
                    let result = SymbolMapper.newSymbols(symbols: symbols)
                    listener.value?.subscriptionChangeListener?.symbolsRemoved(symbols: Set(result))
                }
            }
        }
    }

    static let subscriptionClosedCallback: dxfg_ObservableSubscriptionChangeListener_function_subscriptionClosed
    = {_, context in
        if let context = context {
            let listener: AnyObject = bridge(ptr: context)
            if let listener = listener as? WeakSubscriptionChangeListener {
                listener.value?.subscriptionChangeListener?.subscriptionClosed()
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

        if let nativeSubscriptionChangeListener = nativeSubscriptionChangeListener {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread,
                                          dxfg_DXFeedSubscription_removeChangeListener(
                                            thread,
                                            subscription,
                                            nativeSubscriptionChangeListener))
            _ = try? ErrorCheck.nativeCall(thread,
                                           dxfg_JavaObjectHandler_release(
                                            thread,
                                            &(nativeSubscriptionChangeListener.pointee.handler)))
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

    /// - Throws: GraalException. Rethrows exception from Java.
    func addChangeListener(_ listener: ObservableSubscriptionChangeListener) throws {
        if subscriptionChangeListener == nil {
            let thread = currentThread()

            let weakListener = WeakSubscriptionChangeListener(value: self)
            subscriptionListener = weakListener
            let voidPtr = bridge(obj: weakListener)

            nativeSubscriptionChangeListener = try ErrorCheck.nativeCall(
                thread,
                dxfg_ObservableSubscriptionChangeListener_new(thread,
                                                              NativeSubscription.symbolsAddedCallback,
                                                              NativeSubscription.symbolsRemovedCallback,
                                                              NativeSubscription.subscriptionClosedCallback,
                                                              voidPtr))
            _ = try ErrorCheck.nativeCall(thread,
                                          dxfg_DXFeedSubscription_addChangeListener(thread,
                                                                                    subscription,
                                                                                    nativeSubscriptionChangeListener))

        }
        subscriptionChangeListener = listener
    }

    /// - Throws: GraalException. Rethrows exception from Java.
    func removeChangeListener(_ listener: ObservableSubscriptionChangeListener) throws {
        if listener === subscriptionChangeListener {
            defer {
                nativeSubscriptionChangeListener = nil
                subscriptionChangeListener = nil
            }
            let thread = currentThread()
            _ = try ErrorCheck.nativeCall(thread,
                                          dxfg_DXFeedSubscription_removeChangeListener(
                                            thread,
                                            subscription,
                                            nativeSubscriptionChangeListener))
            if let nativeSubscriptionChangeListener = nativeSubscriptionChangeListener {
                _ = try ErrorCheck.nativeCall(thread,
                                              dxfg_JavaObjectHandler_release(
                                                thread,
                                                &(nativeSubscriptionChangeListener.pointee.handler)))
            }
        }
    }
}

extension NativeSubscription {
    func setSymbols(_ symbols: [Symbol]) throws {
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
                                      dxfg_DXFeedSubscription_setSymbols(thread,
                                                                         self.subscription,
                                                                         listPointer))
    }

    func getSymbols() throws -> [Symbol] {
        let thread = currentThread()
        let nativeResult = try ErrorCheck.nativeCall(thread,
                                                     dxfg_DXFeedSubscription_getSymbols(thread,
                                                                         self.subscription))
        defer {
            _ = try? ErrorCheck.nativeCall(thread, dxfg_CList_symbol_release(thread, nativeResult))
        }

        let result: [Symbol] = SymbolMapper.newSymbols(symbols: nativeResult).compactMap({ obj in
            obj as? Symbol
        })
        return result
    }
}

extension NativeSubscription {
    func attach(feed: NativeFeed) throws {
        let thread = currentThread()
        try ErrorCheck.nativeCall(thread,
                                  dxfg_DXFeedSubscription_attach(thread,
                                                                 subscription,
                                                                 feed.feed))
    }

    func detach(feed: NativeFeed) throws {
        let thread = currentThread()
        try ErrorCheck.nativeCall(thread,
                                  dxfg_DXFeedSubscription_detach(thread,
                                                                 subscription,
                                                                 feed.feed))
    }
}
