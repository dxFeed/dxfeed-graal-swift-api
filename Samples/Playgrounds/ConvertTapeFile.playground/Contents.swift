import Foundation
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


guard let inputFilePath = Bundle.main.path(forResource: "ConvertTapeFile.in", ofType: nil),
      let outputFilePath = NSURL.fileURL(withPathComponents: [NSTemporaryDirectory(), "ConvertTapeFile.out"])?.path else {
    fatalError("Wrong path to output file")
}

// Determine input and output tapes and specify appropriate configuration parameters.
let inputAddress = "file:\(inputFilePath)[readAs=stream_data,speed=max]"
let outputAddress = "tape:\(outputFilePath)[saveAs=stream_data,format=text]"

// Create input endpoint configured for tape reading.
let inputEndpoint = try DXEndpoint.builder()
    .withRole(.streamFeed) // Prevents event conflation and loss due to buffer overflow.
    .withProperty(DXEndpoint.Property.wildcardEnable.rawValue, "true") // Enables wildcard subscription.
    .withProperty(DXEndpoint.Property.eventTime.rawValue, "true") // Use provided event times.
    .build()

// Create output endpoint configured for tape writing.
let outputEndpoint = try DXEndpoint.builder()
    .withRole(.streamPublisher) // Prevents event conflation and loss due to buffer overflow.
    .withProperty(DXEndpoint.Property.wildcardEnable.rawValue, "true") // Enables wildcard subscription.
    .withProperty(DXEndpoint.Property.eventTime.rawValue, "true") // Use provided event times.
    .build()

// Create and link event processor for all types of events.
// Note: Set of processed event types could be limited if needed.
let eventTypes: [EventCode] = EventCode.allCases.compactMap { eventCode in
    if EventCode.unsupported().contains(eventCode) {
        return nil
    } else {
        return eventCode
    }
}

let feed = inputEndpoint.getFeed()
let subscription = try feed?.createSubscription(eventTypes)

let listener = Listener { anonymCl in
    anonymCl.callback = { events in
        // Here event processing occurs. Events could be modified, removed, or new events added.
        // For example, the below code adds 1 hour to event times:
        // foreach (var e in events)
        // {
        //     e.EventTime += 3600_000
        // }

        // Publish processed events
        let publisher = outputEndpoint.getPublisher()
        try? publisher?.publish(events: events)
    }
    return anonymCl
}

try subscription?.add(listener: listener)

// Subscribe to all symbols.
// Note: Set of processed symbols could be limited if needed.
try subscription?.addSymbols(WildcardSymbol.all)

// Connect output endpoint and start output tape writing BEFORE starting input tape reading.
try outputEndpoint.connect(outputAddress)
// Connect input endpoint and start input tape reading AFTER starting output tape writing.
try inputEndpoint.connect(inputAddress)

// Wait until all data is read and processed, and then gracefully close input endpoint.
try inputEndpoint.awaitNotConnected()
try inputEndpoint.closeAndAWaitTermination()

// Wait until all data is processed and written, and then gracefully close output endpoint.
try outputEndpoint.awaitProcessed()
try outputEndpoint.closeAndAWaitTermination()

print("""
ConvertTapeFile:
\(inputAddress)
has been successfully tapped to
\(outputAddress)
""")

