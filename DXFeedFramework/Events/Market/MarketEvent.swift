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
