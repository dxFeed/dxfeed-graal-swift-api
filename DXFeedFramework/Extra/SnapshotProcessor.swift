//
//  SnapshotProcessor.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 22.08.23.
//

import Foundation

/// Delegate for receiving snapshot and updates in snapshot
public protocol SnapshotDelegate: AnyObject {
    func receiveEvents(_ events: [MarketEvent], isSnapshot: Bool)
}

/// The SnapshotProcessor class is designed to handle candles and provide either a snapshot of the data or updates within an existing snapshot, depending on the specified flags.
public class SnapshotProcessor {

    private var snapshotPart = false
    private var snapshotFull = false

    private weak var snapshotDelegate: SnapshotDelegate?
    private var pending = [IIndexedEvent]()
    private var processEvents = [IIndexedEvent]()
    private var result = [Long: IIndexedEvent]()

    public init() { }

    /// Add delegate for received events
    public func add(_ snapshotDelegate: SnapshotDelegate) {
        self.snapshotDelegate = snapshotDelegate
    }
    /// Remove delegate for received events
    public func removeDelegate() {
        self.snapshotDelegate =  nil
    }

    private func processEvents(events: [MarketEvent]) {
        let isSnapshot = processSnapshotAndTx(events)
        processEventsNow(isSnapshot)
        transactionReceived(isSnapshot)
    }

    private func processSnapshotAndTx(_ events: [MarketEvent]) -> Bool {
        var isSnapshot = false
        for event in events {
            guard let event = event as? IIndexedEvent else {
                continue
            }
            if event.snapshotBegin() {
                snapshotPart = true
                snapshotFull = false
                pending.removeAll()
            }
            if snapshotPart && event.endOrSnap() {
                snapshotPart = false
                snapshotFull = true
            }
            if snapshotPart || event.pending() {
                pending.append(event)
                continue
            }
            isSnapshot = isSnapshot || snapshotFull
            if snapshotFull {
                snapshotFull = false
                processEvents.removeAll()
            }
            if !pending.isEmpty {
                processEvents.append(contentsOf: pending)
                pending.removeAll()
            }
            processEvents.append(event)
        }
        return isSnapshot
    }

    private func processEventsNow(_ isSnapshot: Bool) {
        processEvents.forEach { event in
            if isSnapshot && event.isRemove() {
                result.removeValue(forKey: event.index)
            } else {
                result[event.index] = event
            }
        }
        processEvents.removeAll()
    }

    private func transactionReceived(_ isSnapshot: Bool) {
        if result.isEmpty {
            return
        }
        let list = result.values.sorted { event1, event2 in
            event1.index > event2.index
        }.compactMap { event in
            event as? MarketEvent
        }
        result.removeAll()
        snapshotDelegate?.receiveEvents(list, isSnapshot: isSnapshot)
    }

}

extension SnapshotProcessor: DXEventListener {
    public func receiveEvents(_ events: [MarketEvent]) {
        processEvents(events: events)
    }
}

extension SnapshotProcessor: Hashable {
    public static func == (lhs: SnapshotProcessor, rhs: SnapshotProcessor) -> Bool {
        return lhs === rhs
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine("\(self):\(stringReference(self))")
    }
}
