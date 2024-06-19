import Cocoa
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

let allTypes = [Candle.self,
                Trade.self,
                TradeETH.self,
                Quote.self,
                TimeAndSale.self,
                Profile.self,
                Summary.self,
                Greeks.self,
                Underlying.self,
                TheoPrice.self,
                Order.self,
                AnalyticOrder.self,
                SpreadOrder.self,
                Series.self,
                OptionSale.self]

let argSymbols = ["ETH/USD:GDAX"]
let argTime: String? = nil

// To avoid release inside internal {} scope
let feed = try DXEndpoint.getInstance().connect("demo.dxfeed.com:7300").getFeed()
var feedSubscription: DXFeedSubscription?
let listener = Listener { listener in
    listener.callback = { events in
        events.forEach { event in
            print(event.toString())
        }
    }
    return listener
}

if let argTime = argTime, let time: Long = try DXTimeFormat.defaultTimeFormat?.parse(argTime) {
    let types: [ITimeSeriesEvent.Type] = allTypes.compactMap({ event in
        event as? ITimeSeriesEvent.Type
    })
    let subscription = try feed?.createTimeSeriesSubscription(types)
    try subscription?.add(listener: listener)
    try subscription?.set(fromTime: time)
    try subscription?.addSymbols(argSymbols)
    feedSubscription = subscription
} else {
    let subscription = try feed?.createSubscription(allTypes)
    try subscription?.add(listener: listener)
    try subscription?.addSymbols(argSymbols)
    feedSubscription = subscription
}

// infinity execution
PlaygroundPage.current.needsIndefiniteExecution = true

// to finish execution run this line
PlaygroundPage.current.finishExecution()
