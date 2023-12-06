import Cocoa
import PlaygroundSupport
import DXFeedFramework

class Listener: DXInstrumentProfileUpdateListener, Hashable {
    // Data model to keep all instrument profiles mapped by their ticker symbol
    private var profiles = [String: InstrumentProfile]()
    let collector: DXInstrumentProfileCollector

    init(_ collector: DXInstrumentProfileCollector) {
        self.collector = collector
    }

    func instrumentProfilesUpdated(_ instruments: [DXFeedFramework.InstrumentProfile]) {
        // We can observe REMOVED elements - need to add necessary filtering
        // See javadoc for InstrumentProfileCollector for more details

        // (1) We can either process instrument profile updates manually
        instruments.forEach { ipf in
            if ipf.getIpfType() == .removed {
                // Profile was removed - remove it from our data model
                self.profiles.removeValue(forKey: ipf.symbol)
            } else {
                // Profile was updated - collector only notifies us if profile was changed
                self.profiles[ipf.symbol] = ipf
            }
        }
        print(
"""

Instrument Profiles:
Total number of profiles (1): \(self.profiles.count)
Last modified: \(
(try? DXTimeFormat.defaultTimeFormat?.withMillis?.format(value: collector.getLastUpdateTime())) ?? ""
)
"""
)
    }

    static func == (lhs: Listener, rhs: Listener) -> Bool {
        return lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine("\(self):\(stringReference(self))")
    }

}

// An sample that demonstrates a subscription using InstrumentProfile.
let defaultIpfUrl = "https://demo:demo@tools.dxfeed.com/ipf"

let collector = try DXInstrumentProfileCollector()
let connection = try DXInstrumentProfileConnection(defaultIpfUrl, collector)
// Update period can be used to re-read IPF files, not needed for services supporting IPF "live-update"
try connection.setUpdatePeriod(60000)
try connection.start()
// It is possible to add listener after connection is started - updates will not be missed in this case
let listener = Listener(collector)
try collector.add(listener: listener)

// infinity execution
PlaygroundPage.current.needsIndefiniteExecution = true

// to finish execution run this line
PlaygroundPage.current.finishExecution()
