//
//  InstrumentProfileConnection.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 29.08.23.
//

import Foundation

public class InstrumentProfileConnection {
    private let native: NativeInstrumentProfileConnection
    private let collector: InstrumentProfileCollector

    private var observersSet = ConcurrentSet<AnyHashable>()
    private var observers: [InstrumentProfileConnectionObserver] {
        return observersSet.reader { $0.compactMap { value in value as? InstrumentProfileConnectionObserver } }
    }

    public init(_ address: String, _ collector: InstrumentProfileCollector) throws {
        self.collector = collector
        native = try NativeInstrumentProfileConnection(collector.native, address)
        try native.addListener(self)
    }

    public func getAddress() -> String {
        return native.getAddress()
    }

    public func getUpdatePeriod() -> Long {
        return native.getUpdatePeriod()
    }

    public func setUpdatePeriod(_ value: Long) throws {
        try native.setUpdatePeriod(value)
    }

    public func getLastModified() -> Long {
        return native.getLastModified()
    }

    public func start() throws {
        try native.start()
    }

    public func close() throws {
        try native.close()
    }

    public func add<O>(_ observer: O)
    where O: InstrumentProfileConnectionObserver,
          O: Hashable {
        observersSet.insert(observer)
    }

    public func remove<O>(_ observer: O)
    where O: InstrumentProfileConnectionObserver,
          O: Hashable {
        observersSet.remove(observer)
    }

}

extension InstrumentProfileConnection: NativeIPFConnectionListener {
    func connectionDidChangeState(old: InstrumentProfileConnectionState, new: InstrumentProfileConnectionState) {
        observers.forEach { $0.connectionDidChangeState(old: old, new: new) }
    }
}
