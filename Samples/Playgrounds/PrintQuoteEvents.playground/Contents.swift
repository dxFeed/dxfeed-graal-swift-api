import Foundation
import PlaygroundSupport
import DXFeedFramework

// Empty Listener with handler
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

// A simple sample that shows how to subscribe to quotes for one instruments,
// and print all received quotes to the console.
// Use default DXFeed instance for that data feed address is defined by "dxfeed.properties" file.
// The properties file is copied to the build output directory from the project directory.

// Specified instrument name, for example AAPL, IBM, MSFT, etc.
let symbol = "AAPL"

// Use path to dxfeed.properties with feed address
let propertiesFilePath = Bundle.main.path(forResource: "dxfeed.properties", ofType: nil)
try SystemProperty.setProperty(DXEndpoint.Property.properties.rawValue, propertiesFilePath ?? "")

// Creates a subscription attached to a default DXFeed with a Quote event type.
// The endpoint address to use is stored in the "dxfeed.properties" file.
let subscription = try DXEndpoint.getInstance()
    .getFeed()?
    .createSubscription(EventCode.quote)
let listenerTrade = Listener { listener in
    listener.callback = { events in
        events.forEach { event in
            print(event.toString())
        }
    }
    return listener
}
// Listener must be attached before symbols are added.
try subscription?.add(listener: listenerTrade)
try subscription?.addSymbols(symbol)


// infinity execution
PlaygroundPage.current.needsIndefiniteExecution = true

// to finish execution run this line
PlaygroundPage.current.finishExecution()
