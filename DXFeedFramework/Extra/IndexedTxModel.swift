//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation

class IndexedTxModel {
    class Changes {
        let isSnapshot: Bool
        let source: IndexedEventSource
        let events: [Order]

        init(isSnapshot: Bool,
             source: IndexedEventSource,
             events: [Order]) {
            self.isSnapshot = isSnapshot
            self.source = source
            self.events = events
        }
    }
    var mode: TxMode
    fileprivate var sourceTxDict = [Int: SourceTx]()
    weak var listener: TxModelListener?

    init(mode: TxMode) {
        self.mode = mode
    }

    func setListener(_ listener: TxModelListener) {
        self.listener = listener
    }
}

extension IndexedTxModel: TxModelListener {
    func modelChanged(changes: Changes) {
        self.listener?.modelChanged(changes: changes)
    }
}

extension IndexedTxModel: DXEventListener {
    func receiveEvents(_ events: [MarketEvent]) {
        var sourceTx: SourceTx? = nil
        events.forEach { marketEvent in
            guard let order = marketEvent as? Order else {
                return
            }
            let sourceId = order.eventSource.identifier
            if sourceTx == nil || sourceId != sourceTx?.source.identifier {
                sourceTx = geTxProcessorForEvent(order)
            }
            sourceTx?.processEvent(order)
        }
        onBatchReceived()
    }

    private func geTxProcessorForEvent(_ event: Order) -> SourceTx {
        let sourceId = event.eventSource.identifier
        guard let sourceTx = sourceTxDict[sourceId] else {
            let sourceTx = SourceTx(source: event.eventSource, mode: mode, listener: self)
            sourceTxDict[sourceId] = sourceTx
            return sourceTx
        }
        return sourceTx
    }

    private func onBatchReceived() {
        if mode.isBatchProcessing() {
            notifyListenerForAllSources()
        }
    }

    private func notifyListenerForAllSources() {
        sourceTxDict.values.forEach { sourceTx in
            sourceTx.notifyListener()
        }
    }
}


extension IndexedTxModel: Hashable {
    public static func == (lhs: IndexedTxModel, rhs: IndexedTxModel) -> Bool {
        return lhs === rhs
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine("\(self):\(stringReference(self))")
    }
}


fileprivate class SourceTx {
    private var isPartialSnapshot = false
    private var isCompleteSnapshot = false

    private weak var snapshotDelegate: SnapshotDelegate?
    private var pendingEvents = [Order]()
    private var processedEvents = [Order]()

    let source: IndexedEventSource
    let mode: TxMode
    
    weak var listener: TxModelListener?

    init(source: IndexedEventSource, 
         mode: TxMode,
         listener: TxModelListener) {
        self.source = source
        self.mode = mode
        self.listener = listener
    }

    func processEvent(_ event: Order) {
        if event.snapshotBegin() {
            isPartialSnapshot = true
            isCompleteSnapshot = false
            pendingEvents.removeAll()
        }
        if isPartialSnapshot && event.endOrSnap() {
            isPartialSnapshot = false
            isCompleteSnapshot = true
        }
        if event.pending() || isPartialSnapshot {
            pendingEvents.append(event)
            return
        }
        let isSnapshot = isCompleteSnapshot
        if isCompleteSnapshot {
            isCompleteSnapshot = false
            processedEvents.removeAll()
        }
        if !pendingEvents.isEmpty {
            processedEvents.append(contentsOf: pendingEvents)
            pendingEvents.removeAll()
//            if isSnapshot {
//                pendingEvents.trimToSize()
//            }
        }
        processedEvents.append(event)
        onTransactionReceived(isSnapshot)
    }
    private func onTransactionReceived(_ isSnapshot: Bool) {
        if mode.isBatchProcessing() {
            if isSnapshot {
                notifyListener(true)
            }
        } else {
            notifyListener(isSnapshot)
        }
    }
    
    public func notifyListener() {
        notifyListener(false)
    }

    public func notifyListener(_ isSnapshot: Bool) {
        if processedEvents.isEmpty {
            return
        }

        if listener == nil {
            return
        }
        defer {
            processedEvents.removeAll()
            //                if (isSnapshot)
            //                    pendingEvents.trimToSize();
        }
        listener?.modelChanged(changes: IndexedTxModel.Changes(isSnapshot: isSnapshot,
                                                               source: source, 
                                                               events: processedEvents))
    }
}
