import Cocoa
import DXFeedFramework

// Fetches last N days of candles for a specified symbol, prints them, and exits.
// await couldn't use directly in Playground(this is accompanied by errors like: execution stopped with unexpected state)
Task {
    let baseSymbol = CandleSymbol.valueOf("AAPL", [CandlePeriod.day])
    var toTime: Long = Date.now.millisecondsSince1970
    let fromFime: Long = Calendar.current.date(byAdding: .day,
                                                    value: -20,
                                                    to: Date())!.millisecondsSince1970
    let endpoint = try DXEndpoint.getInstance().connect("demo.dxfeed.com:7300")
    let feed = endpoint.getFeed()
    guard let task = feed?.getTimeSeries(type: Candle.self,
                                         symbol: baseSymbol,
                                         fromTime: fromFime,
                                         toTime: toTime) else {
        print("Async task is nil")
        exit(0)
    }
    let result = await task.result
    switch result {
    case .success(let value):
        value?.forEach({ event in
            print(event.toString())
        })
    case .failure(let error):
        print(error)
    }
}
