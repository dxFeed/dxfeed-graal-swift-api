//
//  WeakListener.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 23.05.23.
//

import Foundation

class WeakListener: WeakBox<EndpointListener>, EndpointListener {
    func changeState(old: DXEndpointState, new: DXEndpointState) {
        guard let endpoint = self.value else {
            return
        }
        endpoint.changeState(old: old, new: new)
    }
}
