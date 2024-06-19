//
//  DXEndpointObserver.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 26.05.23.
//

import Foundation

public protocol DXEndpointObserver {
    func endpointDidChangeState(old: DXEndpointState, new: DXEndpointState)
}
