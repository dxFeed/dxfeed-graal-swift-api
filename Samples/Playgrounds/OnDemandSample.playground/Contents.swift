import Cocoa
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

do {
    // get on-demand-only data feed
    let onDemand = try OnDemandService.getInstance()
    let feed = onDemand.getEndpoint()?.getFeed()

    // prepare time format
    let timeZone = try DXTimeZone(timeZoneID: "America/New_York")
    let defaultTimeFormat = try DXTimeFormat.init(timeZone: timeZone)

    // subscribe to Accenture symbol ACN to print its quotes
    let subscription = try feed?.createSubscription(Quote.self)

    let listener = Listener { anonymCl in
        anonymCl.callback = { events in
            events.forEach { event in
                if let quote = event as? Quote {
                    let time = (try? defaultTimeFormat.format(value: quote.eventTime)) ?? ""
                    print("\(time):bid \(quote.bidPrice) / ask \(quote.askPrice)")
                }
            }
        }
        return anonymCl
    }

    try subscription?.add(listener: listener)
    try subscription?.addSymbols("ACN")

    // Watch Accenture drop under $1 on May 6, 2010 "Flashcrash" from 14:47:48 to 14:48:02 EST
    guard let fromDate: Date = try defaultTimeFormat.parse("2010-05-06 14:47:48.000 EST"),
          let toDate: Date = try defaultTimeFormat.parse("2010-05-06 14:48:02.000 EST") else {
        print("Couldn't parse date")
        exit(-1)
    }

    // switch into historical on-demand data replay mode
    try onDemand.replay(date: fromDate)

    //// replaying events until end time reached
    while (onDemand.getTime ?? Date.init(timeIntervalSince1970: 0)) < toDate {
        if let time: Long = onDemand.getTime?.millisecondsSince1970 {
            let timeStr = (try? defaultTimeFormat.format(value: time)) ?? "empty string"
            let connectedState = (try? onDemand.getEndpoint()?.getState()) ?? .notConnected
            print("Current state is \(connectedState), on-demand time is \(timeStr)")
        }
        Thread.sleep(forTimeInterval: 1000)
    }
    // close endpoint completely to release resources
    try onDemand.getEndpoint()?.closeAndAwaitTermination()
} catch {
    print("Exception during sample: \(error)")
}
