//
//  NativeInstrumentProfileConnection.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 01.09.23.
//

import Foundation
@_implementationOnly import graal_api

class NativeInstrumentProfileConnection {
    private let connection: UnsafeMutablePointer<dxfg_ipf_connection_t>
    private let address: String

    private static let defaultUpdatePeriod = Long(1 * 60 * 1000) // 1 minute

    var nativeListener: UnsafeMutablePointer<dxfg_ipf_connection_state_change_listener_t>?
    weak var listener: NativeInstrumentProfileConnectionListener?

    static let listenerCallback: dxfg_ipf_connection_state_change_listener_func = {_, oldState, newState, context in
        if let context = context {
            let endpoint: AnyObject = bridge(ptr: context)
            if let listener =  endpoint as? NativeInstrumentProfileConnection {
                var old = (try? EnumUtil.valueOf(value: InstrumentProfileConnectionState.convert(oldState)))
                var new = (try? EnumUtil.valueOf(value: InstrumentProfileConnectionState.convert(newState)))
                listener.listener?.connectionDidChangeState(old: old ?? .notConnected,
                                                            new: new ?? .notConnected)
            }
        }
    }

    private func removeListener() {
        if let listener = nativeListener {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread,
                                           dxfg_InstrumentProfileConnection_removeStateChangeListener(thread,
                                                                                                      connection,
                                                                                                      listener))
            _ = try? ErrorCheck.nativeCall(thread, dxfg_JavaObjectHandler_release(thread, &(listener.pointee.handler)))
        }
    }
    
    deinit {
        removeListener()

        let thread = currentThread()
        _ = try? ErrorCheck.nativeCall(thread, dxfg_JavaObjectHandler_release(thread,
                                                                              &(connection.pointee.handler)))
    }

    init(_ collector: NativeInstrumentProfileCollector, _ address: String) throws {
        let thread = currentThread()
        connection = try ErrorCheck.nativeCall(thread,
                                               dxfg_InstrumentProfileConnection_createConnection(thread,
                                                                                                 address.toCStringRef(),
                                                                                                 collector.collector))
        self.address = address
    }

    func getAddress() -> String {
        let thread = currentThread()
        let result = try? ErrorCheck.nativeCall(thread,
                                                dxfg_InstrumentProfileConnection_getAddress(
                                                    thread,
                                                    connection))

        return String(pointee: result, default: address)
    }

    func getUpdatePeriod() -> Long {
        let thread = currentThread()
        let result = try? ErrorCheck.nativeCall(thread,
                                                dxfg_InstrumentProfileConnection_getUpdatePeriod(
                                                    thread,
                                                    connection))
        return result ?? NativeInstrumentProfileConnection.defaultUpdatePeriod
    }

    func setUpdatePeriod(_ value: Long) {
        let thread = currentThread()
        _ = try? ErrorCheck.nativeCall(thread,
                                       dxfg_InstrumentProfileConnection_setUpdatePeriod(
                                        thread,
                                        connection,
                                        value))
    }

    private func getState() throws -> InstrumentProfileConnectionState {
        let thread = currentThread()
#warning("TODO: Check undefined symbol for dxfg_InstrumentProfileConnection_getState")

        //        let result = try ErrorCheck.nativeCall(thread,
        //                                                dxfg_InstrumentProfileConnection_getState(
        //                                                    thread,
        //                                                    connection))
        //        if let state = InstrumentProfileConnectionState.convert(result) {
        //            return state
        //        }
        return InstrumentProfileConnectionState.notConnected
    }

    func getLastModified() -> Long {
        let thread = currentThread()
        let result = try? ErrorCheck.nativeCall(thread,
                                                dxfg_InstrumentProfileConnection_getLastModified(
                                                    thread,
                                                    connection))
        return result ?? 0
    }

    func start() throws {
        let thread = currentThread()
        _ = try ErrorCheck.nativeCall(thread,
                                      dxfg_InstrumentProfileConnection_start(
                                        thread,
                                        connection))
    }

    func close() throws {
        let thread = currentThread()
        _ = try ErrorCheck.nativeCall(thread,
                                      dxfg_InstrumentProfileConnection_close(
                                        thread,
                                        connection))
    }

    func addListener(_ listener: NativeInstrumentProfileConnectionListener) throws {
        removeListener()        
        let voidPtr = bridge(obj: self)
        let thread = currentThread()
        let listener = try ErrorCheck.nativeCall(thread,
                                                 dxfg_IpfPropertyChangeListener_new(
                                                    thread,
                                                    NativeInstrumentProfileConnection.listenerCallback,
                                                    voidPtr))
        self.nativeListener = listener

        try ErrorCheck.nativeCall(currentThread(),
                                  dxfg_InstrumentProfileConnection_addStateChangeListener(
                                    thread,
                                    connection,
                                    self.nativeListener))
    }

    func waitUntilCompleted(_ timeInMs: Long) {
        let thread = currentThread()
        _ = try? ErrorCheck.nativeCall(thread,
                                       dxfg_InstrumentProfileConnection_waitUntilCompleted(
                                        thread,
                                        connection,
                                        timeInMs))
    }

}
