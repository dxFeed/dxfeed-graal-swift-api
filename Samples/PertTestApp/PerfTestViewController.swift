//
//  PerfTestViewController.swift
//  TestApp
//
//  Created by Aleksey Kosylo on 07.06.23.
//

import UIKit
import DXFeedFramework

class PerfTestViewController: UIViewController {
    let diagnostic = Diagnostic()

    let numberFormatter = NumberFormatter()
    let cpuFormatter = NumberFormatter()

    private var endpoint: DXEndpoint?
    private var subscription: DXFeedSubcription?

    var symbols = ["ETH/USD:GDAX"]
    var blackHoleInt: Int64 = 0

    var isConnected = false
    var timer = DXFTimer(timeInterval: 2)

    @IBOutlet var connectionStatusLabel: UILabel!
    @IBOutlet var connectButton: UIButton!
    @IBOutlet var addressTextField: UITextField!

    @IBOutlet var rateOfEventsLabel: UILabel!
    @IBOutlet var rateOfEventsCounter: UILabel!

    @IBOutlet var rateOfListenersLabel: UILabel!
    @IBOutlet var rateOfListenersCounter: UILabel!

    @IBOutlet var numberOfEventsLabel: UILabel!
    @IBOutlet var numberOfEventsCounter: UILabel!

    @IBOutlet var currentCpuLabel: UILabel!
    @IBOutlet var currentCpuCounter: UILabel!

    @IBOutlet var peakCpuUsageLabel: UILabel!
    @IBOutlet var peakCpuUsageCounter: UILabel!

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
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0

        cpuFormatter.numberStyle = .decimal
        cpuFormatter.maximumFractionDigits = 2

        self.view.backgroundColor = .tableBackground

        try? SystemProperty.setProperty(DXEndpoint.ExtraPropery.heartBeatTimeout.rawValue, "10s")
        timer.eventHandler = {
            self.updateUI()
        }
        timer.resume()
    }

    fileprivate func updateText(_ metrics: Metrics) {
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
        let metrics = diagnostic.getMetrics()
        diagnostic.updateCpuUsage()
//        print("---------------------------------------------------")
//        print("Event speed      \(numberFormatter.string(from: metrics.rateOfEvent)!) events/s")
//        print("Listener Calls   \(numberFormatter.string(from: metrics.rateOfListeners)!) calls/s")
        DispatchQueue.main.async {
            self.updateText(metrics)
        }
    }

    func updateConnectButton() {
        self.connectButton.setTitle(self.isConnected ? "Disconnect" : "Connect", for: .normal)
    }

    @IBAction func connectTapped(_ sender: Any) {
        if isConnected {
            try? endpoint?.disconnect()
            subscription = nil
        } else {
            guard let address = addressTextField.text else {
                return
            }
            endpoint = try? DXEndpoint.builder().withRole(.feed).build()
            endpoint?.add(observer: self)
            try? endpoint?.connect(address)

            subscription = try? endpoint?.getFeed()?.createSubscription(.timeAndSale)
            try? subscription?.add(observer: self)
            try? subscription?.addSymbols(symbols)
            diagnostic.cleanTime()
        }
    }
}

extension PerfTestViewController: DXEndpointObserver {
    func endpointDidChangeState(old: DXEndpointState, new: DXEndpointState) {
        DispatchQueue.main.async {
            self.isConnected = new == .connected
            self.updateConnectButton()

            self.connectionStatusLabel.text = new.convetToString()
        }
    }
}

extension PerfTestViewController: DXEventListener {
    func receiveEvents(_ events: [MarketEvent]) {
        let count = events.count
        diagnostic.updateCounters(Int64(count))

        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            events.forEach { self.blackHoleInt ^= $0.eventTime }
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
