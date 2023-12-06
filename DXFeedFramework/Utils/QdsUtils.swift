//
//  QdsUtils.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 05.12.23.
//

import Foundation

public class QdsUtils {
    public static func execute(_ parameters: [String]) throws {
        try NativeQdsUtils.execute(parameters)
    }
}
