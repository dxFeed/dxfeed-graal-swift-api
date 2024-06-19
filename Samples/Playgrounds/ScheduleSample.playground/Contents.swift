import Cocoa
import DXFeedFramework

func findNext5Days(_ profile: InstrumentProfile, time: Long, separator: String) throws -> String {
    let schedule = try DXSchedule(instrumentProfile: profile)
    var day: ScheduleDay? = try schedule.getDayByTime(time: time)
    var dates = [String]()
    dates.append("5 next holidays for \(profile.symbol):")
    for _ in 0..<5 {
        day = try day?.getNext(filter: DayFilter.holiday)
        dates.append("\(day?.yearMonthDay ?? 0)")
    }
    return dates.joined(separator: separator)
}

func getSessions(_ profile: InstrumentProfile, time: Long) throws -> String {
    let schedule = try DXSchedule(instrumentProfile: profile)
    let session = try schedule.getSessionByTime(time: time)
    let nextTradingSession = session.isTrading ? session : try session.getNext(filter: .trading)
    let nearestSession = try schedule.getNearestSessionByTime(time: time, filter: .trading)

    func sessionDescription(_ session: ScheduleSession?) -> String {
        guard let session = session else {
            return ""
        }
        return session.toString()
    }
    return """
Current session for \(profile.symbol): \(sessionDescription(session))
Next trading session for \(profile.symbol): \(sessionDescription(nextTradingSession))
Nearest trading session for \(profile.symbol): \(sessionDescription(nearestSession))
"""
}

func checkAllSchedules(_ profiles: [InstrumentProfile]) {
    var successes = 0
    profiles.forEach { profile in
        do {
            _ = try DXSchedule(instrumentProfile: profile)
            _ = try DXSchedule.getTradingVenues(profile: profile)
            successes += 1
        } catch {
            print("Error getting schedule for \(profile.symbol)(\(profile.tradingHours)): \(error)")
        }
    }

    print(
"""
Checked \(profiles.count) instrument profiles: \(successes) successes, \((profiles.count - successes)) failures
""")

}

// A sample program that demonstrates different use cases of Schedule API.
let symbol = "AAPL"
let time = "2011-05-26-14:15:00"

guard let defaultFile = Bundle.main.path(forResource: "schedule.properties", ofType: nil),
      let profileFile = Bundle.main.path(forResource: "sample.ipf.zip", ofType: nil) else {
    fatalError("Wrong path to output file")
}

let fileManager = FileManager.default

try DXSchedule.setDefaults(Data(contentsOf: URL(filePath: defaultFile)))
let reader = DXInstrumentProfileReader()
let profiles = try reader.readFromFile(address: profileFile)?.reduce(into: [String: InstrumentProfile]()) {
    $0[$1.symbol] = $1
}
guard let profiles = profiles else {
    fatalError("IPF Profiles is nil for \(profileFile)")
}
print("Loaded \(profiles.count) instrument profiles")
checkAllSchedules(Array(profiles.values))
guard let profile = profiles[symbol.stringValue] else {
    fatalError("Could not find profile for \(symbol)")
}
print("Found profile for \(symbol): \(profile.descriptionStr)")
let format = DateFormatter()
format.dateFormat = "yyyy-MM-dd-HH:mm:ss"
var timeArgument = format.date(from: time)?.timeIntervalSince1970 ?? 0

let timeInt = Long(timeArgument * 1000)
format.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
print("Using timestamp \(format.string(from: Date(timeIntervalSince1970: timeArgument)))")
print(try findNext5Days(profile, time: timeInt, separator: " "))
print(try getSessions(profile, time: timeInt))
