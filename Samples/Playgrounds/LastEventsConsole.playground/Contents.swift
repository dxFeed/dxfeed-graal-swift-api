import PlaygroundSupport
import UIKit
import DXFeedFramework

/**
 * This sample demonstrates a way to subscribe to the big world of symbols with dxFeed API, so that the events are
 * updated and cached in memory of this process, and then take snapshots of those events from memory whenever
 * they are needed. This example repeatedly reads symbol name from the console and prints a snapshot of its last
 * quote, trade, summary, and profile events.
 */

let records = "Quote,Trade,Summary,Profile"
let symbols = "http://dxfeed.s3.amazonaws.com/masterdata/ipf/demo/mux-demo.ipf.zip"

let endpoint = try DXEndpoint.builder()
    .withProperty("dxfeed.qd.subscribe.ticker", records + " " + symbols)
    .build().connect("demo.dxfeed.com:7300")

guard let feed = endpoint.getFeed() else {
    exit(-1)
}

func fetchData(feed: DXFeed, symbol: String) throws {
    print("begin fetching for \(symbol)")

    /*
     * The first step is to extract promises for all events that we are interested in. This way we
     * can get an event even if we have not previously subscribed for it.
     */
    let qPromise = try feed.getLastEventPromise(type: Quote.self, symbol: symbol)
    let tPromise = try feed.getLastEventPromise(type: Trade.self, symbol: symbol)
    let sPromise = try feed.getLastEventPromise(type: Summary.self, symbol: symbol)
    /*
     * All promises are put into a list for convenience.
     */
    var promises = [qPromise, tPromise, sPromise]
    /*
     * Profile events are composite-only. They are not available for regional symbols like
     * "IBM&N" and the attempt to retrieve never completes (will timeout), so we don't event try.
     */
    if !MarketEventSymbols.hasExchangeCode(symbol) {
        var pPromise = try feed.getLastEventPromise(type: Profile.self, symbol: symbol)
        promises.append(pPromise)
    }

    /*
     * If the events are available in the in-memory cache, then the promises will be completed immediately.
     * Otherwise, a request to the upstream data provider is sent. Below we combine promises using
     * Promises utility class from DXFeed API in order to wait for at most 1 second for all of the
     * promises to complete. The last event promise never completes exceptionally and we don't
     * have to specially process a case of timeout, so "awaitWithoutException" is used to continue
     * normal execution even on timeout. This sample prints a special message in the case of timeout.
     */
    if try Promise.allOf(promises: promises)?.awaitWithoutException(millis: 1000) == false {
        print("Request timed out")
    }
    /*
     * The combination above is used only to ensure a common wait of 1 second. Promises to individual events
     * are completed independently and the corresponding events can be accessed even if some events were not
     * available for any reason and the wait above had timed out. This sample just prints all results.
     * "null" is printed when the event is not available.
     */
    try promises.forEach { pr in
        print(try pr.getResult()?.toString() ?? "Null result for \(pr)")
    }
    print("end fetching for \(symbol)")
}

// Just UI for symbol input
class V: UIViewController {
    var textField = UITextField()
    var feed: DXFeed!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false

        textField.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        textField.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        textField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15).isActive = true
        textField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15).isActive = true
        textField.placeholder = "Type symbols to get their quote, trade, summary, and profile event snapshots"
        textField.delegate = self
    }
}

extension V: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        do {
            try fetchData(feed: feed, symbol: textField.text ?? "")
        } catch {
            print("Error during fetching: \(error)")
        }
        textField.text = ""
        return true
    }
}

let view = V()
view.feed = feed
view.view.frame = CGRect(x: 0, y: 0, width: 400, height: 150)


PlaygroundPage.current.liveView = view.view
PlaygroundPage.current.needsIndefiniteExecution = true



