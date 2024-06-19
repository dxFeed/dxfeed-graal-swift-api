//
//  DXEndpointState.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 23.05.23.
//

import Foundation

/// A list of endpoint states.
public enum DXEndpointState {
    /// Endpoint was created by is not connected to remote endpoints.
    case notConnected
    /// The ``DXEndpoint/connect(_:)`` method was called to establish connection to remove endpoint,
    /// but connection is not actually established yet or was lost.
    case connecting
    /// The connection to remote endpoint is established.
    case connected
    /// Endpoint was ``DXEndpoint/close()``
    case closed
}
