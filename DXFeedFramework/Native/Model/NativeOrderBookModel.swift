//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation
@_implementationOnly import graal_api

class NativeOrderBookModel {
    private class WeakModel: WeakBox<NativeOrderBookModel> { }

    let native: UnsafeMutablePointer<dxfg_order_book_model_t>?
    var nativeListener: UnsafeMutablePointer<dxfg_order_book_model_listener_t>?

    weak var listener: OrderBookModelListener?
    
    private static let listeners = ConcurrentArray<WeakModel>()

    private static let finalizeCallback: dxfg_finalize_function = { _, context in
        if let context = context {
            let endpoint: AnyObject = bridge(ptr: context)
            if let listener =  endpoint as? WeakModel {
                NativeOrderBookModel.listeners.removeAll(where: {
                    return $0 === listener
                })
            }
        }
    }

    static let listenerCallback: dxfg_order_book_model_listener_function = {_, _, context in
        if let context = context {
            let listener: AnyObject = bridge(ptr: context)
            if let listener =  listener as? WeakModel {
                guard let subscription = listener.value else {
                    return
                }
                ThreadManager.insertPthread()
                subscription.listener?.modelChanged()
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

    init() throws {
        let thread = currentThread()
        native = try ErrorCheck.nativeCall(thread, dxfg_OrderBookModel_new(thread))
    }

    func attach(feed: NativeFeed) throws {
        let thread = currentThread()
        try ErrorCheck.nativeCall(thread, dxfg_OrderBookModel_attach(thread, native, feed.feed))
    }

    func detach(feed: NativeFeed) throws {
        let thread = currentThread()
        try ErrorCheck.nativeCall(thread, dxfg_OrderBookModel_detach(thread, native, feed.feed))
    }

    func close() throws {
        let thread = currentThread()
        try ErrorCheck.nativeCall(thread, dxfg_OrderBookModel_close(thread, native))
    }

    func clear() throws {
        let thread = currentThread()
        try ErrorCheck.nativeCall(thread, dxfg_OrderBookModel_clear(thread, native))
    }

    func getFilter() throws -> OrderBookModelFilter {
        let thread = currentThread()
        let filter = try ErrorCheck.nativeCall(thread, dxfg_OrderBookModel_getFilter(thread, native))
        return OrderBookModelFilter.fromNative(native: dxfg_order_book_model_filter_t(UInt32(filter)))
    }

    func setFilter(_ filter: OrderBookModelFilter) throws {
        let thread = currentThread()
        try ErrorCheck.nativeCall(thread,
                                  dxfg_OrderBookModel_setFilter(thread,
                                                                native,
                                                                filter.toNative()))
    }

    func getSymbol() throws -> String? {
        let thread = currentThread()
        let symbol = try ErrorCheck.nativeCall(thread, dxfg_OrderBookModel_getSymbol(thread, native))
        return String(nullable: symbol)
    }

    func setSymbol(_ symbol: String?) throws {
        let thread = currentThread()
        try ErrorCheck.nativeCall(thread, dxfg_OrderBookModel_setSymbol(thread, native, symbol?.toCStringRef()))
    }

    func getLotSize() throws -> Int32 {
        let thread = currentThread()
        return try ErrorCheck.nativeCall(thread, dxfg_OrderBookModel_getLotSize(thread, native))
    }

    func setLotSize(_ size: Int32) throws {
        let thread = currentThread()
        try ErrorCheck.nativeCall(thread, dxfg_OrderBookModel_setLotSize(thread, native, size))
    }

    func getBuyOrders() throws -> NativeObservableListModel {
        let thread = currentThread()
        let model = try ErrorCheck.nativeCall(thread, dxfg_OrderBookModel_getBuyOrders(thread, native))
        return NativeObservableListModel(native: model)
    }

    func getSellOrders() throws -> NativeObservableListModel {
        let thread = currentThread()
        let model = try ErrorCheck.nativeCall(thread, dxfg_OrderBookModel_getSellOrders(thread, native))
        return NativeObservableListModel(native: model)
    }

    
    fileprivate func clearNativeListeners() {
        if let nativeListener = nativeListener {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread,
                                           dxfg_OrderBookModel_removeListener(thread,
                                                                              native,
                                                                              nativeListener))
            _ = try? ErrorCheck.nativeCall(thread,
                                           dxfg_JavaObjectHandler_release(thread,
                                                                          &(nativeListener.pointee.handler)))
        }
    }
    
    func addListener(_ listener: OrderBookModelListener?) throws {
        clearNativeListeners()
        self.listener = listener

        let weakModel = WeakModel(value: self)
        NativeOrderBookModel.listeners.append(newElement: weakModel)
        let voidPtr = bridge(obj: weakModel)
        let thread = currentThread()
        let listener = try ErrorCheck.nativeCall(thread,
                                                 dxfg_OrderBookModelListener_new(thread,
                                                                                 NativeOrderBookModel.listenerCallback,
                                                                                 voidPtr))

        try ErrorCheck.nativeCall(thread, dxfg_Object_finalize(thread,
                                                               &(listener.pointee.handler),
                                                               NativeOrderBookModel.finalizeCallback,
                                                               voidPtr))
        self.nativeListener = listener
        _ = try ErrorCheck.nativeCall(thread,
                                      dxfg_OrderBookModel_addListener(thread,
                                                                      native,
                                                                      self.nativeListener))
    }
}
