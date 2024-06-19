//
//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation
@_implementationOnly import graal_api

/// Native wrapper over the Java com.dxfeed.api.DxFeedSubscription class.
/// The location of the imported functions is in the header files "dxfg_subscription.h".
class NativeObservableSubscription {
    private class WeakSubscriptionChangeListener: WeakBox<NativeObservableSubscription> { }

    let subscription: UnsafeMutablePointer<dxfg_observable_subscription_t>?

    private var subscriptionListener: WeakSubscriptionChangeListener?
    var nativeSubscriptionChangeListener: UnsafeMutablePointer<dxfg_observable_subscription_change_listener_t>?

    weak var subscriptionChangeListener: ObservableSubscriptionChangeListener?

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
        if let subscription = subscription {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread,
                                           dxfg_JavaObjectHandler_release(thread,
                                                                          &(subscription.pointee.handler)))
        }

        if let nativeSubscriptionChangeListener = nativeSubscriptionChangeListener {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread,
                                           dxfg_ObservableSubscription_removeChangeListener(
                                            thread,
                                            subscription,
                                            nativeSubscriptionChangeListener))
            _ = try? ErrorCheck.nativeCall(thread,
                                           dxfg_JavaObjectHandler_release(
                                            thread,
                                            &(nativeSubscriptionChangeListener.pointee.handler)))
        }
    }

    init(subscription: UnsafeMutablePointer<dxfg_observable_subscription_t>?) {
        self.subscription = subscription
    }

    func isClosed() -> Bool {
        let thread = currentThread()
        let success = try? ErrorCheck.nativeCall(thread, dxfg_ObservableSubscription_isClosed(thread,
                                                                                              self.subscription))
        guard let success = success else {
            return true
        }
        return success != 0
    }

    /// - Throws: ``GraalException``. Rethrows exception from Java.
    func addChangeListener(_ listener: ObservableSubscriptionChangeListener) throws {
        if subscriptionChangeListener == nil {
            let thread = currentThread()

            let weakListener = WeakSubscriptionChangeListener(value: self)
            subscriptionListener = weakListener
            let voidPtr = bridge(obj: weakListener)

            nativeSubscriptionChangeListener = try ErrorCheck.nativeCall(
                thread,
                dxfg_ObservableSubscriptionChangeListener_new(thread,
                                                              NativeObservableSubscription.symbolsAddedCallback,
                                                              NativeObservableSubscription.symbolsRemovedCallback,
                                                              NativeObservableSubscription.subscriptionClosedCallback,
                                                              voidPtr))
            _ = try ErrorCheck.nativeCall(thread,
                                          dxfg_ObservableSubscription_addChangeListener(thread,
                                                                                    subscription,
                                                                                    nativeSubscriptionChangeListener))

        }
        subscriptionChangeListener = listener
    }

    /// - Throws: ``GraalException``. Rethrows exception from Java.
    func removeChangeListener(_ listener: ObservableSubscriptionChangeListener) throws {
        if listener === subscriptionChangeListener {
            defer {
                nativeSubscriptionChangeListener = nil
                subscriptionChangeListener = nil
            }
            let thread = currentThread()
            _ = try ErrorCheck.nativeCall(thread,
                                          dxfg_ObservableSubscription_removeChangeListener(
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
