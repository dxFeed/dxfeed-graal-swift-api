//
//  ScheduleCommand.swift
//  Tools
//
//  Created by Aleksey Kosylo on 09.10.23.
//

import Foundation
import DXFeedFramework

class ScheduleCommand: ToolsCommand {
    var cmd = "ScheduleSample"

    var shortDescription = "A sample program that demonstrates different use cases of Schedule API."

    var fullDescription: String =
    """
    A sample program that demonstrates different use cases of Schedule API.

    Usage:
      usage: ScheduleSample  <defaults>  <profiles>  <symbol>  [time]

    Where:
    <defaults>  is a URL to Schedule API defaults file
    <profiles>  is a URL to IPF file
    <symbol>    is a ticker symbol used for sample
    [time]      is a time used for sample in a format yyyy-MM-dd-HH:mm:ss

    sample: ScheduleSample  schedule.properties.zip  sample.ipf.zip  IBM  2011-05-26-14:15:00

    """

    func execute() {
        var arguments: [String]!
        do {
            arguments = try ArgumentParser().parse(ProcessInfo.processInfo.arguments, requiredNumberOfArguments: 3)
        } catch {
            print(fullDescription)
        }
        do {
            let defaultFile = arguments[1]
            let profileFile = arguments[2]
            let symbol = arguments[3]

            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: defaultFile) {
                throw ArgumentParserException.error(message: "File \(defaultFile) doesn't exist")
            }
            try DXSchedule.setDefaults(Data(contentsOf: URL(filePath: defaultFile)))
            
            let reader = DXInstrumentProfileReader()
            let profiles = try reader.readFromFile(address: profileFile)?.reduce(into: [String: InstrumentProfile]()) {
                $0[$1.symbol] = $1
            }
            guard let profiles = profiles else {
                fatalError("IPF Profiles is nil for \(profileFile)")
            }
            print("Loaded \(profiles.count) instrument profiles")
            if arguments.count == 5 {
                let time = arguments[4]
            }


            checkAllSchedules(Array(profiles.values))
        } catch {
            print("ScheduleSample error: \(error)")
        }
    }

    private func checkAllSchedules(_ profiles: [InstrumentProfile]) {
        var successes = 0
        profiles.forEach { profile in
            do {
                let schedule = try DXSchedule(instrumentProfile: profile)
                let venues = try DXSchedule.getTradingVenues(profile: profile)
                successes += 1
            } catch {
                print("Error getting schedule for \(profile.symbol)(\(profile.tradingHours)): \(error)")
            }
        }

        print("Checked \(profiles.count)  instrument profiles: \(successes) successes, \((profiles.count - successes)) failures");

    }
}
