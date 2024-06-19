import Cocoa
import DXFeedFramework

// Write events to a tape file.

// Create an appropriate endpoint.
let endpoint = try DXEndpoint.builder()
// Is required for tape connector to be able to receive everything.
    .withProperty(DXEndpoint.Property.wildcardEnable.rawValue, "true")
    .withRole(.publisher)
    .build()

let pathComponents = [NSTemporaryDirectory(), "WriteTapeFile.out.txt"]
guard let outputFilePath = NSURL.fileURL(withPathComponents: pathComponents)?.path else {
    fatalError("Wrong path to output file")
}

// Connect to the address, remove [format=text] or change on [format=binary] for binary format
try endpoint.connect("tape:\(outputFilePath)[format=text]")
// Get publisher.
let publisher = endpoint.getPublisher()

// Creates new Quote market events.
let quote1 = Quote("TEST1")
Optional(quote1).map {
    $0.bidPrice = 10.1
    $0.askPrice = 10.2
}
let quote2 = Quote("TEST2")
Optional(quote2).map {
    $0.bidPrice = 17.1
    $0.askPrice = 18.1
}

// Publish events.
try publisher?.publish(events: [quote1, quote2])

// Wait until all data is written, close, and wait until it closes.
try endpoint.awaitProcessed()
try endpoint.closeAndAwaitTermination()

// Just print content of result file
let resultTxtFile = try NSString(contentsOf: URL(filePath: outputFilePath), encoding: NSUTF8StringEncoding)
print("""
Result content of \(outputFilePath):
\(resultTxtFile)
""")
