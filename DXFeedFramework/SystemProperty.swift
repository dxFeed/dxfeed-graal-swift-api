//
//  SystemProperty.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 16.03.2023.
//

import Foundation

public class SystemProperty {
    public static func setProperty(_ key: String, _ value: String) throws {
        try NativeProperty.setProperty(key, value)
    }

    public static func getProperty(_ key: String) -> String? {
        return NativeProperty.getProperty(key)
    }
}
