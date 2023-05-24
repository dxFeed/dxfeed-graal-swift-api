//
//  EndpointListener.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 23.05.23.
//

import Foundation

protocol EndpointListener: AnyObject {
    func changeState(old: EndpointState, new: EndpointState)
}
