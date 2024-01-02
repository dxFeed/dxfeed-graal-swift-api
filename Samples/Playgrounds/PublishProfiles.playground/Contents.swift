import UIKit
import PlaygroundSupport
import DXFeedFramework

class PublishListener: ObservableSubscriptionChangeListener {
    let publisher: DXPublisher

    init(publisher: DXPublisher) {
        self.publisher = publisher
    }

    func symbolsAdded(symbols: Set<AnyHashable>) {
        var events = [MarketEvent]()
        symbols.forEach { symbol in
            if let sSymbol = symbol as? Symbol {
                if sSymbol.stringValue.hasSuffix(":TEST") {
                    var profile = Profile(sSymbol.stringValue)
                    profile.descriptionStr = "test symbol"
                    events.append(profile)
                }
            }
        }
        try? publisher.publish(events: events)
    }

    func symbolsRemoved(symbols: Set<AnyHashable>) {
        // nothing to do here
    }

    func subscriptionClosed() {
        // nothing to do here
    }
}

let address = ":7700"

let endpoint = try DXEndpoint.create(.publisher).connect(address)
let publisher = endpoint.getPublisher()
let listener = PublishListener(publisher: publisher!)
let subscription = try publisher?.getSubscription(EventCode.profile)
try subscription?.addChangeListener(listener)

// infinity execution
PlaygroundPage.current.needsIndefiniteExecution = true

// to finish execution run this line
PlaygroundPage.current.finishExecution()
