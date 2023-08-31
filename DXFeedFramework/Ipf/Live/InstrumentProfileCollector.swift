//
//  InstrumentProfileCollector.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 29.08.23.
//

import Foundation

public class InstrumentProfileCollector {

    private lazy var native: NativeInstrumentProfileCollector? = {
        try? NativeInstrumentProfileCollector()
    }()

    public init() {}
}
