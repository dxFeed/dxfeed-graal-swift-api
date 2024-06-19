//
//  DXInstrumentProfileConnectionState+Ext.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 12.09.23.
//

import Foundation

public extension DXInstrumentProfileConnectionState {
    func convetToString() -> String {
        var status = "Not connected 🔴"
        switch self {
        case .notConnected:
            status = "Not connected 🔴"
        case .connecting:
            status = "Connecting 🟠"
        case .connected:
            status = "Connected 🟢"
        case .closed:
            status = "Closed 🔴"
        case .completed:
            status = "Completed 🟢"
        }
        return status
    }
}
