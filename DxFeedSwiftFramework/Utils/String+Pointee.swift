//
//  String+Pointee.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 23.05.23.
//

import Foundation

extension String {
    public init(pointee: UnsafePointer<CChar>!, default value: String = "") {
        if pointee != nil {
            self =  String(utf8String: pointee) ?? value
        } else {
            self = value
        }
    }
    
    func toCStringRef() -> UnsafeMutablePointer<CChar> {
        return UnsafeMutablePointer<CChar>(mutating: (self as NSString).utf8String!)
    }
}
