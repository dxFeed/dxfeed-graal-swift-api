//
//  DXInstrumentProfileConnection.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 29.08.23.
//

import Foundation
/// Connects to an instrument profile URL and reads instrument profiles with support of
/// streaming live updates.
///
/// Please see Instrument Profile Format documentation for complete description.
///
/// The key different between this class and ``DXInstrumentProfileReader`` is that the later just reads
/// a snapshot of a set of instrument profiles, while this classes allows to track live updates, e.g.
/// addition and removal of instruments.
///
/// To use this class you need an address of the data source from you data provider. The name of the IPF file can
/// also serve as an address for debugging purposes.
///
/// If long-running processing of instrument profile is needed, then it is better to use
/// ``DXInstrumentProfileUpdateListener/instrumentProfilesUpdated(_:)`` notification
/// to schedule processing task in a separate thread.
public class DXInstrumentProfileConnection {
    private let native: NativeInstrumentProfileConnection
    private let collector: DXInstrumentProfileCollector

    private var observersSet = ConcurrentWeakSet<AnyObject>()
    private var observers: [DXInstrumentProfileConnectionObserver] {
        return observersSet.reader { $0.allObjects.compactMap { value in value as? DXInstrumentProfileConnectionObserver } }
    }

    /// Creates instrument profile connection with a specified address and collector.
    ///
    /// Address may be just "<host>:<port>" of server, URL, or a file path.
    /// The "[update=<period>]" clause can be optionally added at the end of the address to
    /// specify an ``getUpdatePeriod()`` via an address string.
    /// Default update period is 1 minute.
    ///
    /// Connection needs to be ``start()`` to begin an actual operation.
    ///
    /// - Parameters:
    ///   - address: address address.
    ///   - collector: instrument profile collector to push updates into.
    /// - Returns: new instrument profile connection.
    /// - Throws: GraalException. Rethrows exception from Java.
    public init(_ address: String, _ collector: DXInstrumentProfileCollector) throws {
        self.collector = collector
        native = try NativeInstrumentProfileConnection(collector.native, address)
        try native.addListener(self)
    }

    /// Returns the address of this instrument profile connection.
    ///
    /// It does not include additional options specified as part of the address.
    public func getAddress() -> String {
        return native.getAddress()
    }

    /// Returns update period in milliseconds.
    ///
    /// It is period of an update check when the instrument profiles source does not support live updates
    /// and/or when connection is dropped.
    /// Default update period is 1 minute, unless overriden in an
    /// ``init(_:_:)`` in address string.
    public func getUpdatePeriod() -> Long {
        return native.getUpdatePeriod()
    }

    /// Changes update period in milliseconds.
    ///
    /// - Throws: GraalException. Rethrows exception from Java.
    public func setUpdatePeriod(_ value: Long) throws {
        try native.setUpdatePeriod(value)
    }

    /// Returns state of this instrument profile connections.
    ///
    /// - Throws: GraalException. Rethrows exception from Java.
    public func getState() throws -> DXInstrumentProfileConnectionState {
        return try native.getState()
    }

    /// Returns last modification time (in milliseconds) of instrument profiles or zero if it is unknown.
    ///
    /// Note, that while the time is represented in milliseconds, the actual granularity of time here is a second.
    ///
    /// - Returns: last modification time (in milliseconds) of instrument profiles or zero if it is unknown.
    public func getLastModified() -> Long {
        return native.getLastModified()
    }

    /// Starts this instrument profile connection.
    ///
    /// This connection's state immediately changes to
    /// ``DXInstrumentProfileConnectionState/connecting`` and the actual connection establishment proceeds in the background.
    ///
    /// - Throws: GraalException. Rethrows exception from Java.
    public func start() throws {
        try native.start()
    }

    /// Closes this instrument profile connection. This connection's state immediately changes to
    ///
    /// ``DXInstrumentProfileConnectionState/closed`` and the background update procedures are terminated.
    ///
    /// - Throws: GraalException. Rethrows exception from Java.
    public func close() throws {
        try native.close()
    }

    /// Synchronously waits for full first snapshot read with the specified timeout.
    public func waitUntilCompleted(_ timeInMs: Long) {
        native.waitUntilCompleted(timeInMs)
    }

    /// Adds observer that is notified about changes in ``getState()`` property.
    /// Installed observer can be removed with
    /// ``remove(observer:)`` method.
    public func add<O>(observer: O)
    where O: DXInstrumentProfileConnectionObserver,
          O: Hashable {
        observersSet.insert(observer)
    }

    /// Removes observer that is notified about changes in ``getState()`` property.
    /// It removes the observer that was previously installed with
    /// ``add(observer:)`` method.
    public func remove<O>(observer: O)
    where O: DXInstrumentProfileConnectionObserver,
          O: Hashable {
        observersSet.remove(observer)
    }

}

extension DXInstrumentProfileConnection: NativeIPFConnectionListener {
    func connectionDidChangeState(old: DXInstrumentProfileConnectionState, new: DXInstrumentProfileConnectionState) {
        observers.forEach { $0.connectionDidChangeState(old: old, new: new) }
    }
}
