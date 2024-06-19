//
//  DXEndpointObserver.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 26.05.23.
//

import Foundation

/// Notifies a change in the state of this endpoint.
public protocol DXEndpointObserver: AnyObject {
    /// Fired when state changed
    /// 
    /// - Parameters:
    ///     - old: The old state of endpoint
    ///     - new: The new state of endpoint
    func endpointDidChangeState(old: DXEndpointState, new: DXEndpointState)
}
