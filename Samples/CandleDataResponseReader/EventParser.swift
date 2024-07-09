//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation
import DXFeedFramework

protocol EventParser {
    func parse(_ csv: String) throws -> [MarketEvent]
}

extension EventParser {
    private static func parseFlags(_ string: String) -> Int32 {
        var result: Int32 = 0
        string.split(separator: ",").forEach { value in
            switch String(value) {
            case "TX_PENDING":
                result = result | Candle.txPending
            case "REMOVE_EVENT":
                result = result | Candle.removeEvent
            case "SNAPSHOT_BEGIN":
                result = result | Candle.snapshotBegin
            case "SNAPSHOT_END":
                result = result | Candle.snapshotEnd
            case "SNAPSHOT_SNIP":
                result = result | Candle.snapshotSnip
            default:
                print("Undefined event flag \(value)")
            }
        }
        return result
    }

    static func parseEventflags(_ value: String) -> Int32 {
        // it is events flags
        if !value.isEmpty {
            let prefix = "EventFlags="
            if value.hasPrefix(prefix) {
                return parseFlags(String(value.dropFirst(prefix.count)))
            }
        }
        return 0
    }
}
