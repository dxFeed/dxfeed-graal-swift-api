import Foundation
import DXFeedFramework

//Empty Listener with handler
class Listener: DXEventListener, Hashable {

    static func == (lhs: Listener, rhs: Listener) -> Bool {
        lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine("\(self):\(stringReference(self))")
    }
    var callback: ([MarketEvent]) -> Void = { _ in }

    func receiveEvents(_ events: [MarketEvent]) {
        self.callback(events)
    }

    init(overrides: (Listener) -> Listener) {
        _ = overrides(self)
    }
}


var file: String = ""
var types: [EventCode] = [.quote]
var symbols = "AAPL"
var eventCounter = 0

// Create endpoint specifically for file parsing.
var endpoint = try DXEndpoint.create(.streamFeed)
var feed = endpoint.getFeed()

// Subscribe to a specified event and symbol.
var sub = try feed?.createSubscription(types)
let listener = Listener { anonymCl in
    anonymCl.callback = { events in
        events.forEach { event in
            eventCounter += 1
            print("\(eventCounter): \(event)")
        }
    }
    return anonymCl
}
try sub?.add(listener: listener)

// Add symbols.
try sub?.addSymbols(symbols)

// Connect endpoint to a file.
try endpoint.connect("file:\(file)[speed=max]")

// Wait until file is completely parsed.
try endpoint.awaitNotConnected()

// Close endpoint when we're done.
// This method will gracefully close endpoint, waiting while data processing completes.
try endpoint.closeAndAWaitTermination()
