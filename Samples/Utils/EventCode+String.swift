//
//  EventCode+String.swift
//  PerfTestCL
//
//  Created by Aleksey Kosylo on 21.09.23.
//

import Foundation
import DXFeedFramework

extension EventCode {
    init(string: String) {
        switch string.lowercased() {
        case "quote":
            self = .quote
        case "timeandsale":
            self = .timeAndSale
        case "candle":
            self = .candle
        default:
            fatalError("Please, handle this case: \(string)")
        }
    }
}
