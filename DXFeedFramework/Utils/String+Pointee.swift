//
//  String+Pointee.swift
//  DXFeedFramework
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

    public init?(nullable pointee: UnsafePointer<CChar>!) {
        if pointee != nil {
            self =  String(utf8String: pointee) ?? ""
        } else {
            return nil
        }
    }

    func toCStringRef() -> UnsafeMutablePointer<CChar> {
        return UnsafeMutablePointer<CChar>(mutating: (self as NSString).utf8String!)
    }

    func toCStringRef() -> UnsafePointer<CChar> {
        return UnsafePointer<CChar>((self as NSString).utf8String!)
    }
}
