//
//  ConnectEventListener.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 21.09.23.
//

import Foundation
import DXFeedFramework

class ConnectEventListener: AbstractEventListener {
    override func handleEvents(_ events: [MarketEvent]) {
        events.forEach { event in
            print(event.toString())
        }
    }
}
