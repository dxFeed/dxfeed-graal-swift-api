//
//  String+Range.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 07.08.23.
//

import Foundation

extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [String.Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }

    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }

    func ranges<S: StringProtocol>(of string: S,
                                   options: String.CompareOptions = [],
                                   start: Int,
                                   end: Int) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.index(self.startIndex, offsetBy: start)
        let endIndex = self.index(self.startIndex, offsetBy: end)
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }

    public func lastIndex(of element: String, start: Int) -> Int {
        let ranges = ranges(of: element, start: 0, end: start)
        return ranges.last?.lowerBound.distance(in: self) ?? -1
    }

    public func firstIndex(of element: String, start: Int) -> Int {
        let ranges = ranges(of: element, start: start, end: self.length)
        return ranges.first?.lowerBound.distance(in: self) ?? -1
    }
}

extension StringProtocol {

    var length: Int {
        return count
    }

    subscript (index: Int) -> String {
        return self[index ..< index + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[Swift.min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< Swift.max(0, toIndex)]
    }

    subscript (range: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: Swift.max(0, Swift.min(length, range.lowerBound)),
                                            upper: Swift.min(length, Swift.max(0, range.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}

extension Collection {
    func distance(to index: Index) -> Int { distance(from: startIndex, to: index) }
}

extension String.Index {
    func distance<S: StringProtocol>(in string: S) -> Int { string.distance(to: self) }
}
