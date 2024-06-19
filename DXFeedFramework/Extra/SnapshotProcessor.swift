//
//  SnapshotProcessor.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 22.08.23.
//

import Foundation

public protocol SnapshotDelegate {
    func receiveEvents(_ events: [MarketEvent], isSnapshot: Bool)
}

public class SnapshotProcessor {

    private var snapshotPart = false
    private var snapshotFull = false
    private var txState = false
    private var snapshotDelegate: SnapshotDelegate?
    private var pendingEvents = [IIndexedEvent]()

    public func add(snapshotDelegate: SnapshotDelegate) {
        self.snapshotDelegate = snapshotDelegate
    }

    private func processSnapshotAndTx(event: MarketEvent) -> Bool {
        guard let event = event as? IIndexedEvent else {
            return false
        }
        let eventFlags = event.eventFlags
        let tx = (eventFlags & Candle.txPending) != 0 // txPending
        if (eventFlags & Candle.snapshotBegin) != 0 { // snapshotBegin
            snapshotPart = true
            snapshotFull = false
            pendingEvents.removeAll() // remove any unprocessed leftovers on new snapshot
        }
        // Process snapshot end after snapshot begin was received
        if (snapshotPart && isSnapshotEnd(event)) {
            snapshotPart = false
            snapshotFull = true
        }
        if (tx || snapshotPart) {
            // defer processing of this event while snapshot in progress or tx pending
            pendingEvents.append(event)
            return false // return -- do not process event right now
        }
        // will need to trim temp data structures to size when finished processing snapshot
        let trimToSize = snapshotFull
        // process deferred "snapshot end" by removing previous events from this source
        if (snapshotFull) {
            //            clearImpl();
            snapshotFull = false
        }
        // process deferred orders (before processing this event)
        if !pendingEvents.isEmpty {
            //            processEventsNow.addAll(pendingEvents);
            pendingEvents.removeAll()
//            if trimToSize {
//                pendingEvents.trimToSize() // Don't need memory we held for snapshot -- let GC do its work
//            }
        }
        // add to process this event right now
        //        processEventsNow.add(event)
        return trimToSize

    }

    func isSnapshotEnd(_ event: IIndexedEvent) -> Bool {
        return (event.eventFlags & (Candle.snapshotEnd | Candle.snapshotSnip)) != 0
    }
}

extension SnapshotProcessor: DXEventListener {
    public func receiveEvents(_ events: [MarketEvent]) {
        events.forEach { mEvent in
            _ = processSnapshotAndTx(event: mEvent)
        }
    }
}

extension SnapshotProcessor: Hashable {
    public static func == (lhs: SnapshotProcessor, rhs: SnapshotProcessor) -> Bool {
        return lhs === rhs
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine("\(self)")
    }
}

