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
        switch string {
        case "Quote":
            self = .quote
        case "TimeAndSale":
            self = .timeAndSale
        default:
            fatalError("Please, handle this case: \(string)")
        }
    }
}
