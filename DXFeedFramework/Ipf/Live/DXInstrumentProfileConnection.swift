//
//  DXInstrumentProfileConnection.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 29.08.23.
//

import Foundation

public class DXInstrumentProfileConnection {
    private let native: NativeInstrumentProfileConnection
    private let collector: DXInstrumentProfileCollector

    private var observersSet = ConcurrentSet<AnyHashable>()
    private var observers: [DXInstrumentProfileConnectionObserver] {
        return observersSet.reader { $0.compactMap { value in value as? DXInstrumentProfileConnectionObserver } }
    }

    public init(_ address: String, _ collector: DXInstrumentProfileCollector) throws {
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
    where O: DXInstrumentProfileConnectionObserver,
          O: Hashable {
        observersSet.insert(observer)
    }

    public func remove<O>(_ observer: O)
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
