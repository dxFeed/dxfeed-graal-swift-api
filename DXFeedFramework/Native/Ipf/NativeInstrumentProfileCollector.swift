//
//  NativeInstrumentProfileCollector.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 31.08.23.
//

import Foundation
@_implementationOnly import graal_api

class NativeInstrumentProfileCollector {
    let collector: UnsafeMutablePointer<dxfg_ipf_collector_t>?

    deinit {
        if let collector = collector {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread,
                                           dxfg_JavaObjectHandler_release(thread,
                                                                          &(collector.pointee.handler)))
        }
    }

    init() throws {
        let thread = currentThread()
        collector = try ErrorCheck.nativeCall(thread, dxfg_InstrumentProfileCollector_new(thread))
    }

    func getLastUpdateTime() -> Long {
        return 0
    }

    func updateInstrumentProfile(profile: InstrumentProfile) {

    }

    func updateInstrumentProfiles(profiles: [InstrumentProfile]) {

    }

    func removeGenerations(generatios: Set<AnyHashable>) {
        
    }

    func view() throws -> NativeCollectorView {
        let thread = currentThread()
        let native = try ErrorCheck.nativeCall(thread, dxfg_InstrumentProfileCollector_view(thread, collector))
        return NativeCollectorView(view: native)
    }

    func setExecutor(_ executor: NativeExecutor) throws {
        let thread = currentThread()
        _ = try ErrorCheck.nativeCall(thread, dxfg_InstrumentProfileCollector_setExecutor(thread,
                                                                                              collector,
                                                                                              executor.executor))
    }

    func getExecutor() throws -> NativeExecutor {
        let thread = currentThread()
        let native = try ErrorCheck.nativeCall(thread, dxfg_InstrumentProfileCollector_getExecutor(thread, collector))
        return NativeExecutor(executor: native)
    }

}
