//
//  IIndexedEvent.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 17.08.23.
//

import Foundation

public protocol IIndexedEvent: IEventType {
    static var txPending: Int32 { get }
    static var removeEvent: Int32 { get }
    static var snapshotBegin: Int32 { get }
    static var snapshotEnd: Int32 { get }
    static var snapshotSnip: Int32 { get }
    static var snapShotMode: Int32 { get }

    var eventSource: IndexedEventSource { get }
    var eventFlags: Int32 { get set }
    var index: Long { get set }
}

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
