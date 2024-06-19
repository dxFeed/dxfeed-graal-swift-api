//
//  MarketEvent.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 05.06.23.
//

import Foundation

public protocol MarketEvent {
    var type: EventCode { get }
}
