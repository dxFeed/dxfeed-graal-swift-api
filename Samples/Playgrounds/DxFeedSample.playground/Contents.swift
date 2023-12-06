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

// Creates multiple event listener and subscribe to Quote and Trade events.
// Use default DXFeed instance for that data feed address is defined by "dxfeed.properties" file.
let symbol = "AAPL"

// Use path to dxfeed.properties with feed address
let propertiesFilePath = Bundle.main.path(forResource: "dxfeed.properties", ofType: nil)
try SystemProperty.setProperty(DXEndpoint.Property.properties.rawValue, propertiesFilePath ?? "")

let subscriptionQuote = try DXEndpoint.getInstance()
    .getFeed()?
    .createSubscription(EventCode.quote)
// Listener must be attached before symbols are added.
let listener = Listener { listener in
    listener.callback = { events in
        events.forEach { event in
            print("Mid = \((event.quote.bidPrice + event.quote.askPrice) / 2)")
        }
    }
    return listener
}
try subscriptionQuote?.add(listener: listener)
try subscriptionQuote?.addSymbols(symbol)

let subscriptionTrade = try DXEndpoint.getInstance()
    .getFeed()?
    .createSubscription([EventCode.trade, EventCode.quote])
let listenerTrade = Listener { listener in
    listener.callback = { events in
        events.forEach { event in
            print(event.toString())
        }
    }
    return listener
}
// Listener must be attached before symbols are added.
try subscriptionTrade?.add(listener: listenerTrade)
try subscriptionTrade?.addSymbols(symbol)

// infinity execution
PlaygroundPage.current.needsIndefiniteExecution = true

// to finish execution run this line
PlaygroundPage.current.finishExecution()
