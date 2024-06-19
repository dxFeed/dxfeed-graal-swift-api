//
//  InstrumentProfileConnectionObserver.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 01.09.23.
//

import Foundation

public protocol InstrumentProfileConnectionObserver {
    func connectionDidChangeState(old: InstrumentProfileConnectionState, new: InstrumentProfileConnectionState)
}
