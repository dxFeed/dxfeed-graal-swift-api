//
//  DXInstrumentProfileConnectionObserver.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 01.09.23.
//

import Foundation

/// Notifies a change in the state of this connection.
public protocol DXInstrumentProfileConnectionObserver {
    /// Fired when state changed
    ///
    /// - Parameters:
    ///     - old: The old state of endpoint
    ///     - new: The new state of endpoint
    func connectionDidChangeState(old: DXInstrumentProfileConnectionState, new: DXInstrumentProfileConnectionState)
}
