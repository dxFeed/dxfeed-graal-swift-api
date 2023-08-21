//
//  IndexedEventSource.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 17.08.23.
//

import Foundation

public class IndexedEventSource {
    let identifier: Int
    let name: String

    static let defaultSource =  IndexedEventSource(identifier: 0, name: "DEFAULT")

    init(identifier: Int, name: String) {
        self.name = name
        self.identifier = identifier
    }

    func toString() -> String {
        return name
    }
}

extension IndexedEventSource: Equatable {
    public static func == (lhs: IndexedEventSource, rhs: IndexedEventSource) -> Bool {
        return lhs === rhs || lhs.identifier == rhs.identifier
    }
}
