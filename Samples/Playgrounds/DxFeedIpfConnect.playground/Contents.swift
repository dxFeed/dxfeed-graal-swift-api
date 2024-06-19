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

// An sample that demonstrates a subscription using InstrumentProfile.
// Use default DXFeed instance for that data feed address is defined by "dxfeed.properties" file.
// The properties file is copied to the build output directory from the project directory.

var type = EventCode.timeAndSale
// You can use local ipf file
var ipfFile = "https://demo:demo@tools.dxfeed.com/ipf"

// Use path to dxfeed.properties with feed address
let propertiesFilePath = Bundle.main.path(forResource: "dxfeed.properties", ofType: nil)
try SystemProperty.setProperty(DXEndpoint.Property.properties.rawValue, propertiesFilePath ?? "")

print("Reading instruments from \(ipfFile)")
guard let profiles = try DXInstrumentProfileReader().readFromFile(address: ipfFile) else {
    fatalError("No profiles in \(ipfFile)")
}
// This is just a sample, any arbitrary filtering may go here.
let symbols = profiles.filter({ ipf in
    ipf.getIpfType() == .stock
}).map({ profile in
    profile.symbol
})

print("Selected symbols are: \(symbols)")
let subscription = try DXEndpoint.getInstance().getFeed()?.createSubscription(type)
let listener = Listener { listener in
    listener.callback = { events in
        // Prints all received events.
        events.forEach { event in
            print(event.toString())
        }
    }
    return listener
}
// Listener must be attached before symbols are added.
try subscription?.add(listener: listener)
// Adds specified symbol.
try subscription?.addSymbols(symbols)


// infinity execution
PlaygroundPage.current.needsIndefiniteExecution = true

// to finish execution run this line
PlaygroundPage.current.finishExecution()
