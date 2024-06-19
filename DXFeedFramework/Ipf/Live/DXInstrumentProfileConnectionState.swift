//
//  DXInstrumentProfileConnectionState.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 01.09.23.
//

import Foundation

/// Instrument profile connection state.
public enum DXInstrumentProfileConnectionState {
    /// Instrument profile connection is not started yet.
    /// ``DXInstrumentProfileConnection/start()`` was not invoked yet.
    case notConnected
    /// Connection is being established.
    case connecting
    /// Connection was established.
    case connected
    /// Initial instrument profiles snapshot was fully read (this state is set only once).
    case completed
    /// Instrument profile connection was ``DXInstrumentProfileConnection/close()``.
    case closed
}
