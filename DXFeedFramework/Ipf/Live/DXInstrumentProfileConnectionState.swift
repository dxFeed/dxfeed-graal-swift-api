//
//  DXInstrumentProfileConnectionState.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 01.09.23.
//

import Foundation

public enum DXInstrumentProfileConnectionState {
    case notConnected
    case connecting
    case connected
    case completed
    case closed
}
