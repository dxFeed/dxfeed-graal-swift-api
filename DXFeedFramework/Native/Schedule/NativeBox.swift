//
//  NativeBox.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 19.09.23.
//

import Foundation
@_implementationOnly import graal_api

/// Just box for graal structure.
///
/// Please, override deinit to correct deallocation graal structure
class NativeBox<T> {
    let native: UnsafeMutablePointer<T>
    init(native: UnsafeMutablePointer<T>) {
        self.native = native
    }
}
