//
//  IIndexedEvent.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 17.08.23.
//

import Foundation

public protocol IIndexedEvent: IEventType {
    var txPending: Int64 { get }
    var removeEvent: Int64 { get }
    var snapshotBegin: Int64 { get }
    var snapshotEnd: Int64 { get }
    var snapshotSnip: Int64 { get }
    var snapShotMode: Int64 { get }
}

extension IIndexedEvent {
    var txPending: Int64 {
        return 0x01
    }
    var removeEvent: Int64 {
        return 0x02
    }
    var snapshotBegin: Int64 {
        return 0x04
    }
    var snapshotEnd: Int64 {
        return 0x08
    }
    var snapshotSnip: Int64 {
        return 0x10
    }
    var snapShotMode: Int64 {
        return 0x40
    }
}
