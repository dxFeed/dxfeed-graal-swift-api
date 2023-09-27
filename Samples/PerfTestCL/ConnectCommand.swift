//
//  ConnectCommand.swift
//  Tools
//
//  Created by Aleksey Kosylo on 27.09.23.
//

import Foundation
import DXFeedFramework

class ConnectCommand: ToolsCommand {
    var cmd = "Connect"
    var shortDescription = "Connects to specified address(es)."

    var fullDescription  =
"""
Connect
=======

  "address" argument parsing error. Insufficient parameters.

Usage:
  Connect <address> <types> <symbols> [<options>]

Where:

  address (pos. 0)  Required. The address(es) to connect to retrieve data (see "Help address").
                    For Token-Based Authorization, use the following format: "<address>:<port>[login=entitle:<token>]".
  types (pos. 1)    Required. Comma-separated list of dxfeed event types (e.g. Quote, TimeAndSale).
                    Use "all" for all available event types.
  symbols (pos. 2)  Required. Comma-separated list of symbol names to get events for (e.g. "IBM, AAPL, MSFT").
                    Use "all" for wildcard subscription.
                    The "dxfeed.wildcard.enable" property must be set to true to enable wildcard subscription.
  -f, --from-time   From-time for the history subscription in standard formats (see "Help Time Format").
  -s, --source      Order source for the indexed subscription (e.g. NTV, ntv).
  -p, --properties  Comma-separated list of properties (key-value pair separated by an equals sign).
  -t, --tape        Tape all incoming data into the specified file (see "Help Tape").
  -q, --quite       Be quiet, event printing is disabled.

"""
    func execute() {
        var arguments: [String]!

        do {
            arguments = try ArgumentParser().parse(ProcessInfo.processInfo.arguments, numberOfPossibleArguments: 4)
        } catch {
            print(fullDescription)
        }

        let address = arguments[1]
        let types = arguments[2]
        let symbols = arguments[3].components(separatedBy: ",")

        let listener = ConnectEventListener()
        let endpoint = try? DXEndpoint.builder().withRole(.feed).build()
        _ = try? endpoint?.connect(address)

        var subscriptions = [DXFeedSubcription]()
        types.split(separator: ",").forEach { str in
            let subscription = try? endpoint?.getFeed()?.createSubscription(EventCode(string: String(str)))
            try? subscription?.add(observer: listener)
            try? subscription?.addSymbols(symbols)
            if let subscription = subscription {
                subscriptions.append(subscription)
            }
        }
        // Print till input new line
        _ = readLine()

    }
}
