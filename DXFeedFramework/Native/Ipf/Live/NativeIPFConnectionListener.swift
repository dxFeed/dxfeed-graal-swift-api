//
//  NativeInstrumentProfileConnectionListener.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 01.09.23.
//

import Foundation

protocol NativeIPFConnectionListener: AnyObject {
    func connectionDidChangeState(old: InstrumentProfileConnectionState, new: InstrumentProfileConnectionState)
}
