//
//  IpfConnect.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 10.10.23.
//

import Foundation
import DXFeedFramework

class IpfConnect: ToolsCommand {
    var isTools: Bool = false
    lazy var name = {
        stringReference(self)
    }()
    var cmd = "DXFeedIpfConnect"

    var shortDescription = "A sample program that demonstrates IPF Connection"

    var fullDescription: String =
    """
    A sample program that demonstrates IPF Connection

    usage: DXFeedIpfConnect <type> <ipf-file>
    Where:
    <type>     is dxfeed event type (" + eventTypeNames + ")"
    <ipf-file> is name of instrument profiles file

    sample: DXFeedIpfConnect TimeAndSale sample.ipf.zip
    """

    private lazy var arguments: Arguments = {
        do {
            let arguments = try Arguments(ProcessInfo.processInfo.arguments, requiredNumberOfArguments: 2)
            return arguments
        } catch {
            print(fullDescription)
            exit(0)
        }
    }()

    func execute() {
        let eventType = arguments[1]
        let ipfFile = arguments[2]
        try? SystemProperty.setProperty(DXEndpoint.Property.address.rawValue, "demo.dxfeed.com:7300")
        let subscription = try? DXEndpoint.getInstance().getFeed()?.createSubscription([EventCode(string: eventType)])
        try? subscription?.add(observer: self)
        let symbols = getSymbols(fileName: ipfFile)
        try? subscription?.addSymbols(symbols)
        // Print till input new line
        _ = readLine()
    }

    private func getSymbols(fileName: String) -> [String] {
        print("Reading instruments from \(fileName)")
        let profiles = try? DXInstrumentProfileReader().readFromFile(address: fileName)
        print("Selected symbols are:")
        let result =  profiles?.compactMap({ profile in
            // This is just a sample, any arbitrary filtering may go here.
            if profile.type == "STOCK" {
                print("\(profile.symbol) (\(profile.descriptionStr))")
                return profile.symbol
            } else {
                return nil
            }
        })
        return result ?? [String]()
    }
}
extension IpfConnect: Hashable {
    static func == (lhs: IpfConnect, rhs: IpfConnect) -> Bool {
        return lhs === rhs || lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
extension IpfConnect: DXEventListener {
    func receiveEvents(_ events: [DXFeedFramework.MarketEvent]) {
        events.forEach { mEvent in
            print("\(mEvent.eventSymbol): \(mEvent.toString())")
        }
    }
}
