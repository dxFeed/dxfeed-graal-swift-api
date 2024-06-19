//
//  DXEventListener.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 31.05.23.
//

import Foundation
/// The listener delegate for receiving events.
///
public protocol DXEventListener: AnyObject {
    /// Invoked when events of type are received.
    /// 
    /// - Parameters:
    ///   - events: The collection of received events.
    func receiveEvents(_ events: [MarketEvent])
}
