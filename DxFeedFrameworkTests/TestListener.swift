//
//  TestListener.swift
//  DxFeedFrameworkTests
//
//  Created by Aleksey Kosylo on 13.02.2023.
//


import DxFeedFramework
import Foundation

class TestListener: NSObject, DxFSubscriptionListener {
    func receivedEventsCount(_ count: Int) {
    
    }
    
    @objc dynamic var count = 0
    var items = [DxFEvent]()
    func receivedEvents(_ events: [DxFEvent]!) {
        print(events ?? "Empty events")        
        items.append(contentsOf: events)
        count = items.count
        print(count)
    }    
}
