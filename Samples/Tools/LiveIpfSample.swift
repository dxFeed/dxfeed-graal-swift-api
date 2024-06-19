//
//  LiveIpfSample.swift
//  Tools
//
//  Created by Aleksey Kosylo on 09.10.23.
//

import Foundation
import DXFeedFramework

class LiveIpfSample: ToolsCommand {
    var isTools: Bool = false
    lazy var name = {
        stringReference(self)
    }()

    private var ipfList = [InstrumentProfile]()
    private var buffer = [String: InstrumentProfile]()

    static let defaultIpfUrl = "https://demo:demo@tools.dxfeed.com/ipf"

    var cmd = "DXFeedLiveIpfSample"

    var shortDescription = "An sample that demonstrates a subscription using InstrumentProfile."

    var fullDescription: String =
    """
    An sample that demonstrates a subscription using InstrumentProfile.

    Usage:
      usage: DXFeedLiveIpfSample [<ipf-url>]

    Where:

    <ipf-url>  is URL for the instruments profiles.
    Example of url: " + \(LiveIpfSample.defaultIpfUrl)

    """
    var collector: DXInstrumentProfileCollector?
    var connection: DXInstrumentProfileConnection?

    private lazy var arguments: Arguments = {
        do {
            let arguments = try Arguments(ProcessInfo.processInfo.arguments, requiredNumberOfArguments: 1)
            return arguments
        } catch {
            print(fullDescription)
            exit(0)
        }
    }()

    func execute() {
        do {
            collector = try DXInstrumentProfileCollector()
            connection = try DXInstrumentProfileConnection(arguments.count > 1 ? arguments[1] : LiveIpfSample.defaultIpfUrl, collector!)
            // Update period can be used to re-read IPF files, not needed for services supporting IPF "live-update"
            try connection?.setUpdatePeriod(60000)
            connection?.add(listener: self)
            try connection?.start()
            // We can wait until we get first full snapshot of instrument profiles
            connection?.waitUntilCompleted(10000)
            // It is possible to add listener after connection is started - updates will not be missed in this case
            try collector?.add(listener: self)
        } catch {
            print("Error: \(error)")
        }

        _ = readLine()
    }
}

extension LiveIpfSample: DXInstrumentProfileConnectionListener {
    func connectionDidChangeState(old: DXInstrumentProfileConnectionState, new: DXInstrumentProfileConnectionState) {
        print("Connection state: \(new)")
    }
}

extension LiveIpfSample: DXInstrumentProfileUpdateListener {
    func instrumentProfilesUpdated(_ instruments: [DXFeedFramework.InstrumentProfile]) {
        instruments.forEach { ipf in
            if ipf.getIpfType() == .removed {
                self.buffer.removeValue(forKey: ipf.symbol)
            } else {
                self.buffer[ipf.symbol] = ipf
            }
        }
            self.ipfList = self.buffer.map { _, value in
                value
            }.sorted(by: { ipf1, ipf2 in
                ipf1.symbol < ipf2.symbol
            })
        print(
"""

Instrument Profiles:
Total number of profiles (1): \(self.ipfList.count)
Last modified: \(TimeUtil.toLocalDateString(millis: collector?.getLastUpdateTime() ?? 0))
"""
)
    }
}

extension LiveIpfSample: Hashable {
    static func == (lhs: LiveIpfSample, rhs: LiveIpfSample) -> Bool {
        return lhs === rhs || lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

}
