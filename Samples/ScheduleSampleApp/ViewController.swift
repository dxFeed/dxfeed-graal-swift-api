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
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    let dateFormat = "yyyy-MM-dd-HH:mm:ss"
    let defaultIPfUrl = "https://demo:demo@tools.dxfeed.com/ipf?TYPE=STOCK"
    lazy var  dateFormater = {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.color = .white

        view.backgroundColor = .tableBackground
        resultTextView.backgroundColor = .tableBackground

        func changeAppereance(_ textField: UITextField) {
            textField.backgroundColor = .priceBackground
            textField.textColor = .white
            textField.layer.cornerRadius = 10
            textField.clipsToBounds = true
        }

        changeAppereance(timeTextField)
        changeAppereance(symbolTextField)
        resultTextView.textColor = .white

        activityIndicator.isHidden = true
        timeTextField.text = dateFormater.string(from: Date.now)
        // Do any additional setup after loading the view.
    }

    @IBAction func getScheduleTapped(_ sender: Any) {
        let symbol = symbolTextField.text ?? ""
        let currentTime = getCurrentTime()
        if symbol.isEmpty || currentTime == 0 {
            let alert = UIAlertController(title: "Oups",
                                          message: "Please, input symbol and time",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        resultTextView.text = ""
        DispatchQueue.global(qos: .background).async {
            do {
                let profile = DXInstrumentProfileReader()
                let profiles = try profile.readFromFile(address: self.defaultIPfUrl)
                let profilesForSymbol = profiles?.filter({ ipf in
                    ipf.symbol == symbol
                })
                if profilesForSymbol?.count == 0 {
                    self.show(result: "Could not find profile for \(symbol)")
                    return
                }
                let next5Days = try profilesForSymbol?.map({ profile in
                    try self.findNext5Days(profile, time: currentTime)
                })
                let currentSession = try profilesForSymbol?.map({ profile in
                    try self.getSessions(profile, time: currentTime)
                })
                var result = next5Days?.joined(separator: "") ?? ""
                result += "\n"
                result += currentSession?.joined(separator: "") ?? ""
                self.show(result: result)
            } catch {
                let textError = "Error: \(error)"
                print(textError)
                self.show(result: textError)
            }
        }
    }

    private func show(result: String) {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
            self.resultTextView.text = result
        }
    }

    private func findNext5Days(_ profile: InstrumentProfile, time: Long) throws -> String {
        let schedule = try DXSchedule(instrumentProfile: profile)
        var day: ScheduleDay? = try schedule.getDayByTime(time: time)
        var dates = [String]()
        dates.append("5 next holidays for \(profile.symbol): ")
        for _ in 0..<5 {
            day = try day?.getNext(filter: DayFilter.holiday)
            dates.append("\(day?.yearMonthDay ?? 0)")
        }
        return dates.joined(separator: "\n")
    }

    private func getSessions(_ profile: InstrumentProfile, time: Long) throws -> String {
        let schedule = try DXSchedule(instrumentProfile: profile)
        let session = try schedule.getSessionByTime(time: time)
        let nextTradingSession = session.isTrading ? session : try session.getNext(filter: .trading)
        let nearestSession = try schedule.getNearestSessionByTime(time: time, filter: .trading)

        func sessionDescription(_ session: ScheduleSession?) -> String {
            guard let session = session else {
                return ""
            }
            return """
        \(profile.symbol): \(session.type) \
        \(TimeUtil.toLocalDateStringWithoutMillis(millis: session.startTime))\
        -\(TimeUtil.toLocalDateStringWithoutMillis(millis: session.endTime))
        """
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
