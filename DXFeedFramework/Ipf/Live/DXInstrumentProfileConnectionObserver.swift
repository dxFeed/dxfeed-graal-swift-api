//
//  DXInstrumentProfileConnectionObserver.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 01.09.23.
//

import Foundation

public protocol DXInstrumentProfileConnectionObserver {
    func connectionDidChangeState(old: DXInstrumentProfileConnectionState, new: DXInstrumentProfileConnectionState)
}
