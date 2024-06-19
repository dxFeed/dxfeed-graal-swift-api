//
//  SessionFilter.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 18.09.23.
//

import Foundation

public enum SessionFilter: Int, CaseIterable {
    case any = 0
    case trading
    case nonTrading
    case noTrading
    case preMarket
    case regular
    case afterMarket
}
