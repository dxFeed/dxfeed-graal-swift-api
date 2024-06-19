//
//  IEventType.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 17.08.23.
//

import Foundation

public protocol IEventType {
    var eventSymbol: String { get set }
    var eventTime: Int64 { get set }
}
