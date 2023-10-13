//
//  MarketEvent.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 05.06.23.
//

import Foundation

/// Protocol for all market events. All market events are objects that
/// extend this class. Market event classes are simple beans with setter and getter methods for their
/// properties and minimal business logic. All market events have ``type``
/// property that is defined by this class.
public protocol MarketEvent: IEventType {
    var type: EventCode { get }
    func toString() -> String
}

public struct MarketEventConst {
    /// Maximum allowed sequence value.
    public static let maxSequence = Int32((1 << 22) - 1)
}
