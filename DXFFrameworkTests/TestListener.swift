//
//  TestListener.swift
//  DXFFrameworkTests
//
//  Created by Aleksey Kosylo on 13.02.2023.
//


import DXFFramework
import Foundation

class TestListener: NSObject, DXFSubscriptionListener {
    @objc dynamic var count = 0
    var items = [DXFEvent]()
    func receivedEvents(_ events: [DXFEvent]!) {
        print(events ?? "Empty events")        
        items.append(contentsOf: events)
        count = items.count
        print(count)
    }    
}
