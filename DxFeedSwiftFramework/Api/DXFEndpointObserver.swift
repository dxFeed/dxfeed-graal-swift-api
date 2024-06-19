//
//  DXFEndpointObserver.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 26.05.23.
//

import Foundation

public protocol DXFEndpointObserver {
    func endpointDidChangeState(old: DXFEndpointState, new: DXFEndpointState)
}
