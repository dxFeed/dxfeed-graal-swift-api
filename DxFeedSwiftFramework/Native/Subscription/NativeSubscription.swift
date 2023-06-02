//
//  NativeSubscription.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 30.05.23.
//

import Foundation
@_implementationOnly import graal_api

class NativeSubscription {
    let subscription: UnsafeMutablePointer<dxfg_subscription_t>?
    var nativeListener: UnsafeMutablePointer<dxfg_feed_event_listener_t>?
    weak var listener: DXEventListener?
    fileprivate
    //    dxfg_DXFeedEventListener_new
    static let listenerCallback: dxfg_feed_event_listener_function = {_, events, context in
        if let context = context {
            let listener: AnyObject = bridge(ptr: context)
            if let listener =  listener as? NativeSubscription {
                let count = Int(events?.pointee.size ?? 0)
                for index in 0..<count {
                    let element: UnsafeMutablePointer<dxfg_event_type_t>? = events?.pointee.elements[index]
                    element?.withMemoryRebound(to: dxfg_quote_t.self, capacity: 1, { pointer in
                        print(String(pointee: pointer.pointee.market_event.event_symbol, default: "ooops"))
                    })
                }
                print(events ?? "empty events")
                listener.listener?.receiveEvents([])
            }
        }
    }

    deinit {
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
        let voidPtr = bridge(obj: self)
        let thread = currentThread()
        let listener = try ErrorCheck.nativeCall(thread,
                                                 dxfg_DXFeedEventListener_new(thread,
                                                                              NativeSubscription.listenerCallback,
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

        let classes = UnsafeMutablePointer<UnsafeMutablePointer<dxfg_symbol_t>?>
            .allocate(capacity: nativeSymbols.count)
        var iterator = classes
        for code in nativeSymbols {
            iterator.initialize(to: code)
            iterator = iterator.successor()
        }
        let listPointer = UnsafeMutablePointer<dxfg_symbol_list>.allocate(capacity: 1)
        listPointer.pointee.size = Int32(nativeSymbols.count)
        listPointer.pointee.elements = classes
        defer {
            var iterator = classes
            for _ in 0..<nativeSymbols.count {
                iterator.deinitialize(count: 1)
                iterator = iterator.successor()
            }
            classes.deinitialize(count: nativeSymbols.count)
            classes.deallocate()
            listPointer.deinitialize(count: 1)
            listPointer.deallocate()

            nativeSymbols.forEach { SymbolMapper.clearNative(symbol: $0) }
        }

//        var testStruct = dxfg_string_symbol_t(supper: dxfg_symbol_t(type: STRING), symbol: "ETH/USD:GDAX".stringValue.toCStringRef())
//
//        let pointe = withUnsafeMutablePointer(to: &testStruct) {
//            $0
//        }
//        let pointe2 = withUnsafeMutablePointer(to: &testStruct) {
//            $0
//        }
//        var pointer = UnsafeMutablePointer<dxfg_string_symbol_t>.allocate(capacity: 1)
//        pointer.pointee.supper = dxfg_symbol_t(type: STRING)
//        pointer.pointee.symbol = "ETH/USD:GDAX".stringValue.toCStringRef()
//        let classes = UnsafeMutablePointer<UnsafeMutablePointer<dxfg_symbol_t>?>
//            .allocate(capacity: 1)
//        var iterator = classes
//        var castedPointer = pointer.withMemoryRebound(to: dxfg_symbol_t.self, capacity: 1) { $0 }
//        for code in [castedPointer] {
//            let value: UnsafeMutablePointer<Any>? =
//            UnsafeMutablePointer<Any>.allocate(capacity: 1)
//            let casted = code.withMemoryRebound(to: dxfg_string_symbol_t.self, capacity: 1) { $0 }
//            value?.initialize(to: casted.pointee)
//            let lastCated = value?.withMemoryRebound(to: dxfg_symbol_t.self, capacity: 1) { $0 }
//
//            iterator.initialize(to: castedPointer)
//            iterator = iterator.successor()
//        }
//
//
//        let listPointer = UnsafeMutablePointer<dxfg_symbol_list>.allocate(capacity: 1)
//        listPointer.pointee.size = 1
//        listPointer.pointee.elements = classes

        let thread = currentThread()
        let res = try ErrorCheck.nativeCall(thread, dxfg_DXFeedSubscription_addSymbols(thread, self.subscription, listPointer))
//        
        print(res)
    }
}
