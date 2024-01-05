//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import UIKit
import DXFeedFramework

class PerfTestViewController: UIViewController {
    let listener = PerfTestEventListener()
    let printer = PerformanceMetricsPrinter()

    let numberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    let cpuFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    private var endpoint: DXEndpoint?
    private var subscription: DXFeedSubscription?

    var blackHoleInt: Int64 = 0

    var isConnected = false
    var timer = DXFTimer(timeInterval: 2)

    @IBOutlet var connectionStatusLabel: UILabel!
    @IBOutlet var connectButton: UIButton!
    @IBOutlet var addressTextField: UITextField!
    @IBOutlet var symbolsTextField: UITextField!

    @IBOutlet var resultTableView: UITableView!

    var dataSource = [String: String]()
    let soureTitles = ["Rate of events (avg)",
                       "Rate of listener calls",
                       "Number of events in call (avg)",
                       "Current memory usage",
                       "Peak memory usage",
                       "Current CPU usage",
                       "Peak CPU usage",
                       "Running time"]

    override func viewDidLoad() {
        super.viewDidLoad()
        resultTableView.backgroundColor = .tableBackground
        resultTableView.separatorStyle = .none

        self.updateUI()
        self.addressTextField.text = "akosylo-mac.local:6666"
        self.connectionStatusLabel.text = DXEndpointState.notConnected.convetToString()

        self.view.backgroundColor = .tableBackground

        try? SystemProperty.setProperty(DXEndpoint.ExtraPropery.heartBeatTimeout.rawValue, "10s")
        timer.eventHandler = {
            self.updateUI()
        }
        timer.resume()
    }

    fileprivate func updateText(_ metrics: PerformanceMetrics) {
        let rateOfEventsCounter = "\(numberFormatter.string(from: metrics.rateOfEvent)!) events/s"
        let rateOfListenersCounter = "\(numberFormatter.string(from: metrics.rateOfListeners)!) calls/s"
        var eventsIncall = 0.0
        if metrics.rateOfEvent.intValue > 0 && metrics.rateOfListeners.intValue > 0 {
            eventsIncall = metrics.rateOfEvent.doubleValue / metrics.rateOfListeners.doubleValue
        }
        let numberOfEventsCounter = "\(numberFormatter.string(from: NSNumber(value: eventsIncall))!) events"
        let currentCpuCounter = "\(cpuFormatter.string(from: metrics.cpuUsage)!) %"
        let peakCpuUsageCounter = "\(cpuFormatter.string(from: metrics.peakCpuUsage)!) %"
        dataSource = [
            "Rate of events (avg)": rateOfEventsCounter,
            "Rate of listener calls": rateOfListenersCounter,
            "Number of events in call (avg)": numberOfEventsCounter,
            "Current memory usage": "\(cpuFormatter.string(from: metrics.memmoryUsage)!) Mbyte",
            "Peak memory usage": "\(cpuFormatter.string(from: metrics.peakMemmoryUsage)!) Mbyte",
            "Current CPU usage": currentCpuCounter,
            "Peak CPU usage": peakCpuUsageCounter,
            "Running time": "\(metrics.currentTime.stringFromTimeInterval())"
        ]
        resultTableView.reloadData()
    }

    func updateUI() {
        let metrics = listener.metrics()
        listener.updateCpuUsage()
        DispatchQueue.main.async {
            self.printer.update(metrics)
            self.updateText(metrics)
        }
    }

    func updateConnectButton() {
        self.connectButton.setTitle(self.isConnected ? "Disconnect" : "Connect", for: .normal)
    }

    @IBAction func connectTapped(_ sender: Any) {
        if isConnected {
            try? endpoint?.closeAndAwaitTermination()
            subscription = nil
        } else {
            guard let address = addressTextField.text else {
                return
            }
            endpoint = try? DXEndpoint.builder().withRole(.feed).build()
            endpoint?.add(listener: self)
            _ = try? endpoint?.connect(address)

            subscription = try? endpoint?.getFeed()?.createSubscription(TimeAndSale.self)
            try? subscription?.add(listener: listener)
            try? subscription?.addSymbols(symbolsTextField.text ?? "")
            listener.cleanTime()
        }
    }
}

extension PerfTestViewController: DXEndpointListener {
    func endpointDidChangeState(old: DXEndpointState, new: DXEndpointState) {
        DispatchQueue.main.async {
            self.isConnected = new == .connected
            self.updateConnectButton()

            self.connectionStatusLabel.text = new.convetToString()
        }
    }
}

extension PerfTestViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return soureTitles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MetricCellId", for: indexPath)
                as? MetricCell else {
            return UITableViewCell()
        }
        let title = soureTitles[indexPath.row]
        let value = dataSource[title]
        cell.update(title: title, value: value ?? "")

        return cell
    }
}

extension PerfTestViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension PerfTestViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
