//
//  DXInstrumentProfileCollector.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 29.08.23.
//

import Foundation

/// Collects instrument profile updates and provides the live list of instrument profiles.
///
/// This class contains a map that keeps a unique instrument profile per symbol.
/// This class is intended to be used with ``DXInstrumentProfileConnection`` as a repository that keeps
/// profiles of all known instruments. See ``DXInstrumentProfileConnection`` for a usage example.
///
/// As set of instrument profiles stored in this collector can be accessed with ``view()`` method.
/// A snapshot plus a live stream of updates can be accessed with
/// ``add(listener:)`` method.
///
/// Removal of instrument profile is represented by an ``InstrumentProfile`` instance with a
/// ``InstrumentProfile/type`` equal to ``InstrumentProfileType/removed``
public class DXInstrumentProfileCollector {
    private let listeners = ConcurrentWeakHashTable<AnyObject>()
    let native: NativeInstrumentProfileCollector

    /// Creates instrument profile connection.
    ///
    /// - Throws: GraalException. Rethrows exception from Java.
    public init() throws {
        self.native = try NativeInstrumentProfileCollector()
    }
    /// Adds listener that is notified about any updates in the set of instrument profiles.
    ///
    /// If a set of instrument profiles is not empty, then this listener will be immediately
    /// ``DXInstrumentProfileUpdateListener/instrumentProfilesUpdated(_:)``.
    /// - Throws: GraalException. Rethrows exception from Java.
    public func add<O>(listener: O) throws
    where O: DXInstrumentProfileUpdateListener,
          O: Hashable {
              try native.addListener(listener)
              listeners.insert(listener)
          }

    /// Removes listener that is notified about any updates in the set of instrument profiles.
    /// - Throws: GraalException. Rethrows exception from Java.
    public func remove<O>(listener: O)
    where O: DXInstrumentProfileUpdateListener,
          O: Hashable {
              native.removeListener(listener)
              listeners.remove(listener)
          }

    /// Returns last modification time (in milliseconds) of instrument profiles or zero if it is unknown.
    ///
    /// Note, that while the time is represented in milliseconds, the actual granularity of time here is a second.
    ///
    /// - Returns:last modification time (in milliseconds) of instrument profiles or zero if it is unknown.
    public func getLastUpdateTime() -> Long {
        return native.getLastUpdateTime()
    }

    /// Convenience method to update one instrument profile in this collector.
    ///
    /// - Parameters:
    ///   - profile: ip instrument profile.
    /// - Throws: GraalException. Rethrows exception from Java.
    public func updateInstrumentProfile(profile: InstrumentProfile) throws {
        try native.updateInstrumentProfile(profile: profile)
    }

    /// Returns a concurrent view of the set of instrument profiles.
    ///
    /// Note, that removal of instrument profile is represented by an ``InstrumentProfile`` instance with a
    /// ``InstrumentProfile/type`` equal to ``InstrumentProfileType/removed``
    /// Normally, this view exposes only non-removed profiles. However, if iteration is concurrent with removal,
    /// then a removed instrument profile (with a removed type) can be exposed by this view.
    ///
    /// - Returns: a concurrent view of the set of instrument profiles.
    /// - Throws: GraalException. Rethrows exception from Java.
    public func view() throws -> DXProfileIterator {
        let iterator = try native.view()
        return DXProfileIterator(iterator)
    }

    /// Create executor for processing instrument profile update notifications.
    ///
    /// - Returns: true in success case
    /// - Throws: GraalException. Rethrows exception from Java.
    public func createOnConcurrentLinkedQueue() throws -> Bool {
        let nativeExecutor = try NativeExecutor.createOnConcurrentLinkedQueue()
        return try native.setExecutor(nativeExecutor)
    }

    /// Create executor for processing instrument profile update notifications.
    ///
    /// Based on java ScheduledExecutorService.newScheduledThreadPool
    /// - Parameters:
    ///   - numberOfThreads: the number of threads to keep in the pool, even if they are idle
    ///   - nameOfthread: name of threadFactory. The factory to use when the executor creates a new thread
    /// - Returns: true in success case
    /// - Throws: GraalException. Rethrows exception from Java.
    public func createOnScheduledThreadPool(numberOfThreads: Int32,
                                            nameOfthread: String) throws -> Bool {
        let nativeExecutor = try NativeExecutor.createOnScheduledThreadPool(numberOfThreads: numberOfThreads,
                                                                            nameOfthread: nameOfthread)
        return try native.setExecutor(nativeExecutor)
    }

    /// Create executor for processing instrument profile update notifications.
    ///
    /// Based on java ScheduledExecutorService.newFixedThreadPool
    /// - Parameters:
    ///   - numberOfThreads: the number of threads to keep in the pool, even if they are idle
    ///   - nameOfthread: name of threadFactory. The factory to use when the executor creates a new thread
    /// - Returns: true in success case
    /// - Throws: GraalException. Rethrows exception from Java.
    public func createOnFixedThreadPool(numberOfThreads: Int32,
                                        nameOfthread: String) throws -> Bool {
        let nativeExecutor = try NativeExecutor.createOnFixedThreadPool(numberOfThreads: numberOfThreads,
                                                                        nameOfthread: nameOfthread)
        return try native.setExecutor(nativeExecutor)
    }
}

