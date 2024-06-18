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

let address = "demo.dxfeed.com:7300";

func updateTokenAndReconnect() {
    try? DXEndpoint.getInstance().connect("\(address)[login=entitle:\(generateToken())]")
}

func generateToken() -> String {
    let length = Int.random(in: 4...10)
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map { _ in letters.randomElement()! })
}


// Demonstrates how to connect to endpoint requires authentication token, subscribe to market data events,
// and handle periodic token updates.
let endpoint = try DXEndpoint.getInstance()
// Add a listener for state changes to the default application-wide singleton instance of DXEndpoint.
let stateListener = EndpoointStateListener { listener in
    listener.callback = { old, new in
        print("Connection state changed:  \(old) -> \(new)")
    }
    return listener
}
endpoint.add(listener: stateListener)

// Set up a timer to periodically update the token and reconnect every 10 seconds.
// The first connection will be made immediately.
// After reconnection, all existing subscriptions will be re-subscribed automatically.
Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { timer in
    updateTokenAndReconnect()
}.fire()

// Create a subscription for Quote events.
let subscriptionQuote = try endpoint.getFeed()?.createSubscription(Quote.self)
// Listener must be attached before symbols are added.
let listener = Listener { listener in
    listener.callback = { events in
        // Event listener that prints each received event.
        events.forEach { event in
            print(event.toString())
        }
    }
    return listener
}
try subscriptionQuote?.add(listener: listener)

// Add the specified symbol to the subscription.
try subscriptionQuote?.addSymbols("ETH/USD:GDAX")

// Keep the application running indefinitely.
PlaygroundPage.current.needsIndefiniteExecution = true

// to finish execution run this line
PlaygroundPage.current.finishExecution()
