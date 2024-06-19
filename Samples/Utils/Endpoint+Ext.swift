//
//  Endpoint+Ext.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 12.06.23.
//

import Foundation
import DXFeedFramework

extension DXEndpointState {
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
        @unknown default:
            status = "Not connected 🔴"
        }
        return status
    }
}
