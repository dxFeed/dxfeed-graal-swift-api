import Cocoa
import DXFeedFramework

let address = "demo.dxfeed.com:7300"
let symbol = "AAPL"
let endpoint = try DXEndpoint.create().connect(address)
let promise = try endpoint.getFeed()?.getLastEventPromise(type: Profile.self, symbol: symbol)
let profile = try promise?.await(millis: 5000).getResult()
print(profile?.toString())
try endpoint.closeAndAwaitTermination()
