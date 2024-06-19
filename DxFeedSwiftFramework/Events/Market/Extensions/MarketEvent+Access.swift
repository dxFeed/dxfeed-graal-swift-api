//
//  MarketEvent+Access.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 15.06.23.
//

import Foundation

extension MarketEvent {
    public var quote: Quote {
        return (self as? Quote)!
    }
    public var timeAndSale: TimeAndSale {
        return (self as? TimeAndSale)!
    }
    public var trade: Trade {
        return (self as? Trade)!
    }
    public var profile: Profile {
        return (self as? Profile)!
    }
}
