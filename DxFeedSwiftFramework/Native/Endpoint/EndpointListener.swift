//
//  EndpointListener.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 23.05.23.
//

import Foundation

internal protocol EndpointListener: AnyObject {
    func changeState(old: DXEndpointState, new: DXEndpointState)
}
