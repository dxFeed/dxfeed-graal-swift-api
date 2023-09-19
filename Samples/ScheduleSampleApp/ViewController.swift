//
//  ViewController.swift
//  ScheduleSampleApp
//
//  Created by Aleksey Kosylo on 19.09.23.
//

import UIKit
import DXFeedFramework

class ViewController: UIViewController {
    @IBOutlet var timeTextField: UITextField!
    @IBOutlet var getScheduleButton: UIButton!
    @IBOutlet var symbolTextField: UITextField!
    @IBOutlet var resultTextView: UITextView!
    let dateFormat = "yyyy-MM-dd-HH:mm:ss"
    let defaultIPfUrl = "https://demo:demo@tools.dxfeed.com/ipf?TYPE=STOCK"
    lazy var  dateFormater = {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        timeTextField.text = dateFormater.string(from: Date.now)
        // Do any additional setup after loading the view.
    }

    @IBAction func getScheduleTapped(_ sender: Any) {
        do {
            let profile = DXInstrumentProfileReader()
            let profiles = try profile.readFromFile(address: defaultIPfUrl)
            let symbol = symbolTextField.text
            let profilesForSymbol = profiles?.filter({ ipf in
                ipf.symbol == symbol
            })

            let next5Days = try profilesForSymbol?.map({ profile in
                try findNext5Days(profile)
            })
            let currentSession = try profilesForSymbol?.map({ profile in
                try getSessions(profile)
            })
            var result = next5Days?.joined(separator: "") ?? ""
            result += "\n"
            result += currentSession?.joined(separator: "") ?? ""
            resultTextView.text = result
        } catch {
            let textError = "Error: \(error)"
            print(textError)
            resultTextView.text = textError
        }
    }

    private func findNext5Days(_ profile: InstrumentProfile) throws -> String {
        let schedule = try DXSchedule(instrumentProfile: profile)
        var day: ScheduleDay? = try schedule.getDayByTime(time: getCurrentTime())
        var dates = [String]()
        dates.append("5 next holidays for \(profile.symbol): ")
        for _ in 0..<5 {
            day = try day?.getNext(filter: DayFilter.holiday)
            dates.append("\(day?.yearMonthDay ?? 0)")
        }
        return dates.joined(separator: "\n")
    }

    private func getSessions(_ profile: InstrumentProfile) throws -> String {
        let schedule = try DXSchedule(instrumentProfile: profile)
        let session = try schedule.getSessionByTime(time: getCurrentTime())
        let nextTradingSession = session.isTrading ? session : try session.getNext(filter: .trading)
        let nearestSession = try schedule.getNearestSessionByTime(time: getCurrentTime(), filter: .trading)

        func sessionDescription(_ session: ScheduleSession?) -> String {
            guard let session = session else {
                return ""
            }
            return "\(profile.symbol): \(session.type) \(TimeUtil.toLocalDateStringWithoutMillis(millis: session.startTime))-\(TimeUtil.toLocalDateStringWithoutMillis(millis: session.endTime))"
        }
        return """
Current session for \(profile.symbol):
\(sessionDescription(session))
\(sessionDescription(nextTradingSession))
\(sessionDescription(nearestSession))
"""
    }

    private func getCurrentTime() -> Long {
        let date = dateFormater.date(from: timeTextField.text ?? "")
        return Long((date?.timeIntervalSince1970 ?? 0)) * 1000
    }
}
