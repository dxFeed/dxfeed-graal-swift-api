//
//  WeakListener.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 23.05.23.
//

import Foundation

class WeakListener: WeakBox<AnyObject>, EndpointListener {
    func changeState(old: EndpointState, new: EndpointState) {
        guard let endpoint = self.value else {
            return
        }
        if let endpoint = endpoint as? EndpointListener {
            endpoint.changeState(old: old, new: new)
        }
    }
}
