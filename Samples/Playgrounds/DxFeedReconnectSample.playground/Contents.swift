import Cocoa
import PlaygroundSupport
import DXFeedFramework

// Empty Event Listener with handler
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

// Empty Endpoint Listener with handler
class EndpoointStateListener: DXEndpointListener, Hashable {
    func endpointDidChangeState(old: DXFeedFramework.DXEndpointState, new: DXFeedFramework.DXEndpointState) {
        callback(old, new)
    }

    static func == (lhs: EndpoointStateListener, rhs: EndpoointStateListener) -> Bool {
        lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine("\(self):\(stringReference(self))")
    }
    var callback: (DXEndpointState, DXEndpointState) -> Void = { _,_  in }

    init(overrides: (EndpoointStateListener) -> EndpoointStateListener) {
        _ = overrides(self)
    }
}


// Demonstrates how to connect to an endpoint, subscribe to market data events,
// handle reconnections and re-subscribing.
let address = "demo.dxfeed.com:7300" // The address of the DxFeed endpoint.
let symbol = "ETH/USD:GDAX" // The symbol for which we want to receive quotes.

// Create new endpoint and add a listener for state changes.
let endpoint = try DXEndpoint.getInstance()
let stateListener = EndpoointStateListener { listener in
    listener.callback = { old, new in
        print("Connection state changed:  \(old) -> \(new)")
    }
    return listener
}
endpoint.add(listener: stateListener)

// Connect to the endpoint using the specified address.
try endpoint.connect(address)

// Create a subscription for Quote events.
let subscriptionQuote = try endpoint.getFeed()?.createSubscription(Quote.self)
// Listener must be attached before symbols are added.
let listener = Listener { listener in
    listener.callback = { events in
        events.forEach { event in
            print(event.toString())
        }
    }
    return listener
}
try subscriptionQuote?.add(listener: listener)

// Add the specified symbol to the subscription.
try subscriptionQuote?.addSymbols(symbol)

// Wait for five seconds to allow some quotes to be received.
Thread.sleep(forTimeInterval: 5)

// Disconnect from the endpoint.
try endpoint.disconnect()

// Wait for another five seconds to ensure quotes stop coming in.
Thread.sleep(forTimeInterval: 5)

// Reconnect to the endpoint.
// The subscription is automatically re-subscribed, and quotes start coming into the listener again.
// Another address can also be passed on.
try endpoint.connect(address)

// infinity execution
PlaygroundPage.current.needsIndefiniteExecution = true

// to finish execution run this line
PlaygroundPage.current.finishExecution()
