//
//  InstrumentProfileReader.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 29.08.23.
//

import Foundation

public class InstrumentProfileReader {
    private lazy var native: NativeInstrumentProfileReader? = {
        try? NativeInstrumentProfileReader()
    }()

    public init() {}

    public func getLastModified() -> Long {
        return native?.getLastModified() ?? 0
    }

    public func wasComplete() -> Bool {
        return native?.wasComplete() ?? false
    }

    public func readFromFile(address: String) throws -> [InstrumentProfile]? {
        return try native?.readFromFile(address: address)
    }

    public func readFromFile(address: String, user: String, password: String) throws -> [InstrumentProfile]? {
        return try native?.readFromFile(address: address, user: user, password: password)
    }

    public static func resolveSourceURL(address: String) -> String {
        return NativeInstrumentProfileReader.resolveSourceURL(address: address)
    }

    public func read(data: Data, address: String) throws -> [InstrumentProfile]? {
        return try native?.read(data: data, address: address)
    }

    public func readCompressed(data: Data) throws -> [InstrumentProfile]? {
        return try native?.readCompressed(data: data)
    }

    public func read(data: Data) throws -> [InstrumentProfile]? {
        return try native?.read(data: data)
    }
}
