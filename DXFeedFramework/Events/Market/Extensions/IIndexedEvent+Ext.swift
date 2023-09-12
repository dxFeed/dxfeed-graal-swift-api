//
//  IIndexedEvent+Ext.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 11.09.23.
//

import Foundation

/// Used extensions only to overcome swift limitation (cannot use initialized values in protocol)
public extension IIndexedEvent {
    static var txPending: Int32 {
        return 0x01
    }
    static var removeEvent: Int32 {
        return 0x02
    }
    static var snapshotBegin: Int32 {
        return 0x04
    }
    static var snapshotEnd: Int32 {
        return 0x08
    }
    static var snapshotSnip: Int32 {
        return 0x10
    }
    static var snapShotMode: Int32 {
        return 0x40
    }
}
