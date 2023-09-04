//
//  InstrumentProfileCollector.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 29.08.23.
//

import Foundation

public class InstrumentProfileCollector {
    private let listeners = ConcurrentSet<AnyHashable>()
    let native: NativeInstrumentProfileCollector

    public init() throws {
        self.native = try NativeInstrumentProfileCollector()
    }

    public func add<O>(_ observer: O) throws
    where O: InstrumentProfileUpdateListener,
          O: Hashable {
              try listeners.reader { [weak self] in
                  if $0.isEmpty {
                      try self?.native.addListener(self)
                  }
              }
              listeners.insert(observer)
          }

    public func remove<O>(_ observer: O)
    where O: InstrumentProfileUpdateListener,
          O: Hashable {
              listeners.remove(observer)
          }

    public func getLastUpdateTime() -> Long {
        return native.getLastUpdateTime()
    }

    public func updateInstrumentProfile(profile: InstrumentProfile) throws {
        try native.updateInstrumentProfile(profile: profile)
    }

    public func view() throws -> ProfileIterator {
        let iterator = try native.view()
        return ProfileIterator(iterator)
    }

    public func createOnConcurrentLinkedQueue() throws -> Bool {
        let nativeExecutor = try NativeExecutor.createOnConcurrentLinkedQueue()
        return try native.setExecutor(nativeExecutor)
    }

    public func createOnScheduledThreadPool(numberOfThreads: Int32,
                                            nameOfthread: String) throws -> Bool {
        let nativeExecutor = try NativeExecutor.createOnScheduledThreadPool(numberOfThreads: numberOfThreads,
                                                                            nameOfthread: nameOfthread)
        return try native.setExecutor(nativeExecutor)
    }

    public func createOnFixedThreadPool(numberOfThreads: Int32,
                                        nameOfthread: String) throws -> Bool {
        let nativeExecutor = try NativeExecutor.createOnFixedThreadPool(numberOfThreads: numberOfThreads,
                                                                        nameOfthread: nameOfthread)
        return try native.setExecutor(nativeExecutor)
    }
}

extension InstrumentProfileCollector: InstrumentProfileUpdateListener {
    public func instrumentProfilesUpdated(_ instruments: [InstrumentProfile]) {
        listeners.reader { items in
            items.compactMap {
                $0 as? InstrumentProfileUpdateListener
            }.forEach { $0.instrumentProfilesUpdated(instruments) }
        }
    }
}
