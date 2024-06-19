//
//  ListNative+Ext.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 31.05.23.
//

import Foundation
@_implementationOnly import graal_api

extension ListNative where T == dxfg_event_clazz_t {
    func newList() -> UnsafeMutablePointer<dxfg_event_clazz_list_t> {
        let listPointer = UnsafeMutablePointer<dxfg_event_clazz_list_t>.allocate(capacity: 1)
        listPointer.pointee.size = self.size
        listPointer.pointee.elements = self.elements
        return listPointer
    }
}

extension ListNative where T == dxfg_event_type_t {
    func newList() -> UnsafeMutablePointer<dxfg_event_type_list> {
        let listPointer = UnsafeMutablePointer<dxfg_event_type_list>.allocate(capacity: 1)
        listPointer.pointee.size = self.size
        listPointer.pointee.elements = self.elements
        return listPointer
    }
}

extension ListNative where T == dxfg_symbol_t {
    func newList() -> UnsafeMutablePointer<dxfg_symbol_list> {
        let listPointer = UnsafeMutablePointer<dxfg_symbol_list>.allocate(capacity: 1)
        listPointer.pointee.size = self.size
        listPointer.pointee.elements = self.elements
        return listPointer
    }
}


