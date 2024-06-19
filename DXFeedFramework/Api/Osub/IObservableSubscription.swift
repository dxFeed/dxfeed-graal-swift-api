//
//  IObservableSubscription.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 18.08.23.
//

import Foundation

public protocol IObservableSubscription {
    func isClosed() -> Bool
    var eventTypes: Set<EventCode> { get }
    func isContains(_ eventType: EventCode) -> Bool
}
