//
//  MarketEvent.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 05.06.23.
//

import Foundation

public protocol MarketEvent: IEventType {
    var type: EventCode { get }
}

struct MarketEventConst {
    /// Maximum allowed sequence value.
    static let maxSequence = Int32((1 << 22) - 1)
}
