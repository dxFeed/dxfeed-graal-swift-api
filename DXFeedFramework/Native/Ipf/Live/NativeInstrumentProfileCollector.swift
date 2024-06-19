//
//  NativeInstrumentProfileCollector.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 31.08.23.
//

import Foundation
@_implementationOnly import graal_api

/// Native wrapper over the Java com.dxfeed.ipf.live.InstrumentProfileCollector class.
/// The location of the imported functions is in the header files "dxfg_ipf.h".
class NativeInstrumentProfileCollector {
    let collector: UnsafeMutablePointer<dxfg_ipf_collector_t>?
    private var nativeListener: UnsafeMutablePointer<dxfg_ipf_update_listener_t>?

    private weak var listener: DXInstrumentProfileUpdateListener?
    private static let mapper = InstrumentProfileMapper()

    static let listenerCallback: dxfg_ipf_update_listener_function = {_, nativeProfiles, context in
        guard let nativeProfiles = nativeProfiles else {
            return
        }
        if let context = context {
            var profiles = [InstrumentProfile]()
            let listener: AnyObject = bridge(ptr: context)
            if let listener =  listener as? NativeInstrumentProfileCollector {
                let iterator = NativeProfileIterator(nativeProfiles)

                while (try? iterator.hasNext()) ?? false {
                    do {
                        let profile = try iterator.next()
                        profiles.append(profile)
                    } catch {
                        print("NativeInstrumentProfileCollector: excpetion \(error)")
                    }
                }
                listener.listener?.instrumentProfilesUpdated(profiles)

            }
        }
    }

    private func removeListener() {
        if let nativeListener = nativeListener {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread,
                                           dxfg_InstrumentProfileCollector_removeUpdateListener(thread,
                                                                                                self.collector,
                                                                                                nativeListener))
            _ = try? ErrorCheck.nativeCall(thread,
                                           dxfg_JavaObjectHandler_release(thread,
                                                                          &(nativeListener.pointee.handler)))
            self.listener = nil
        }
    }

    deinit {
        removeListener()
        let thread = currentThread()
        if let collector = collector {
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
        let thread = currentThread()
        let result = try? ErrorCheck.nativeCall(thread,
                                                dxfg_InstrumentProfileCollector_getLastUpdateTime(
                                                    thread,
                                                    collector))
        return result ?? 0
    }

    func updateInstrumentProfile(profile: InstrumentProfile) throws {
        let native = NativeInstrumentProfileCollector.mapper.toNative(instrumentProfile: profile)
        defer {
            NativeInstrumentProfileCollector.mapper.releaseNative(native: native)
        }
        let thread = currentThread()
        _ = try ErrorCheck.nativeCall(thread,
                                           dxfg_InstrumentProfileCollector_updateInstrumentProfile(
                                            thread,
                                            collector,
                                            native))
    }

    func view() throws -> NativeProfileIterator {
        let thread = currentThread()
        let native = try ErrorCheck.nativeCall(thread, dxfg_InstrumentProfileCollector_view(thread, collector))
        return NativeProfileIterator(native)
    }

    func setExecutor(_ executor: NativeExecutor) throws -> Bool {
        let thread = currentThread()
        let result = try ErrorCheck.nativeCall(thread, dxfg_InstrumentProfileCollector_setExecutor(thread,
                                                                                          collector,
                                                                                          executor.executor))
        return result == 0
    }

    func getExecutor() throws -> NativeExecutor {
        let thread = currentThread()
        let native = try ErrorCheck.nativeCall(thread, dxfg_InstrumentProfileCollector_getExecutor(thread, collector))
        return NativeExecutor(executor: native)
    }

    func addListener(_ listener: DXInstrumentProfileUpdateListener?) throws {
        removeListener()
        let thread = currentThread()
        self.listener = listener
        let voidPtr = bridge(obj: self)
        let callback = NativeInstrumentProfileCollector.listenerCallback
        let listener = try ErrorCheck.nativeCall(thread,
                                                 dxfg_InstrumentProfileUpdateListener_new(thread,
                                                                                          callback,
                                                                                          voidPtr))
        self.nativeListener = listener
        _ = try ErrorCheck.nativeCall(thread,
                                      dxfg_InstrumentProfileCollector_addUpdateListener(thread,
                                                                                        self.collector,
                                                                                        self.nativeListener))
    }

}
