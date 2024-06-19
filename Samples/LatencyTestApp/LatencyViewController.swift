//
//  LatencyViewController.swift
//  LatencyTest
//
//  Created by Aleksey Kosylo on 14.06.23.
//

import UIKit
import DXFeedFramework

class LatencyViewController: UIViewController {
    let diagnostic = Diagnostic()

    let numberFormatter = NumberFormatter()

    private var endpoint: DXEndpoint?
    private var subscription: DXFeedSubcription?

    var symbols = ["ETH/USD:GDAX"]
    var blackHoleInt: Int64 = 0

    var isConnected = false
    var timer = DXFTimer(timeInterval: 2)

    var dataSource = [String: String]()
    let soureTitles = ["Rate of events (avg), events/s",
                       "Rate of unique symbols per interval",
                       "Min, ms",
                       "Max, ms",
                       "99th percentile, ms",
                       "Mean, ms",
                       "StdDev, ms",
                       "Error, ms",
                       "Sample size (N), events",
                       "Measurement interval, s",
                       "Running time"]

    @IBOutlet var connectionStatusLabel: UILabel!
    @IBOutlet var connectButton: UIButton!
    @IBOutlet var addressTextField: UITextField!

    @IBOutlet var resultTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .tableBackground
        resultTableView.backgroundColor = .tableBackground

        resultTableView.separatorStyle = .none

        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        self.connectionStatusLabel.text = DXEndpointState.notConnected.convetToString()

        addressTextField.text = "mddqa.in.devexperts.com:7400"
        timer.eventHandler = {
            self.updateUI()
        }
        timer.resume()
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
            endpoint?.add(self)
            try? endpoint?.connect(address)

            subscription = try? endpoint?.getFeed()?.createSubscription(.timeAndSale)
            try? subscription?.add(self)

            try? subscription?.addSymbols(symbols)
            diagnostic.cleanTime()
        }
    }

    func updateUI() {
        let metrics = diagnostic.getMetrics()
        DispatchQueue.main.async {
            self.updateText(metrics)
        }
    }

    func updateText(_ metrics: Metrics) {
        let result = """
  Rate of events (avg)     : \(numberFormatter.string(from: metrics.rateOfEvent)!) (events/s)
  Rate of unique symbols   : \(numberFormatter.string(from: metrics.rateOfSymbols)!) (symbols/interval)
  Min                      : \(numberFormatter.string(from: metrics.min)!) (ms)
  Max                      : \(numberFormatter.string(from: metrics.max)!) (ms)
  99th percentile          : \(numberFormatter.string(from: metrics.percentile)!) (ms)
  Mean                     : \(numberFormatter.string(from: metrics.mean)!) (ms)
  StdDev                   : \(numberFormatter.string(from: metrics.stdDev)!) (ms)
  Error                    : \(numberFormatter.string(from: metrics.error)!) (ms)
  Sample size (N)          : \(numberFormatter.string(from: metrics.sampleSize)!) (events)
  Measurement interval     : \(numberFormatter.string(from: metrics.measureInterval)!) (s)
  Running time             : \(metrics.currentTime.stringFromTimeInterval())
"""
        print(result)
        print("---------------------------------------------------------")
        dataSource = [
            "Rate of events (avg), events/s": "\(numberFormatter.string(from: metrics.rateOfEvent)!)",
            "Rate of unique symbols per interval": "\(numberFormatter.string(from: metrics.rateOfSymbols)!)",
            "Min, ms": "\(numberFormatter.string(from: metrics.min)!)",
            "Max, ms": "\(numberFormatter.string(from: metrics.max)!)",
            "99th percentile, ms": "\(numberFormatter.string(from: metrics.percentile)!)",
            "Mean, ms": "\(numberFormatter.string(from: metrics.mean)!)",
            "StdDev, ms": "\(numberFormatter.string(from: metrics.stdDev)!)",
            "Error, ms": "\(numberFormatter.string(from: metrics.error)!)",
            "Sample size (N), events": "\(numberFormatter.string(from: metrics.sampleSize)!)",
            "Measurement interval, s": "\(numberFormatter.string(from: metrics.measureInterval)!)",
            "Running time": "\(metrics.currentTime.stringFromTimeInterval())"
        ]
        self.resultTableView.reloadData()
    }
}

extension LatencyViewController: DXEndpointObserver {
    func endpointDidChangeState(old: DXEndpointState, new: DXEndpointState) {
        DispatchQueue.main.async {
            self.isConnected = new == .connected
            self.updateConnectButton()

            self.connectionStatusLabel.text = new.convetToString()
        }
    }
}

extension LatencyViewController: DXEventListener {
    func receiveEvents(_ events: [MarketEvent]) {
        let currentTime = Int64(Date().timeIntervalSince1970 * 1_000)
        var deltas = [Int64]()
        events.forEach { tsEvent in
            switch tsEvent.type {
            case .quote:
                let quote = tsEvent.quote
                let delta = currentTime - quote.time
                diagnostic.addSymbol(tsEvent.eventSymbol)
                diagnostic.addDeltas(delta)
            case .timeAndSale:
                let timeAndSale = tsEvent.timeAndSale
                let delta = currentTime - timeAndSale.time
                diagnostic.addSymbol(tsEvent.eventSymbol)
                diagnostic.addDeltas(delta)
            case .trade:
                let trade = tsEvent.trade
                let delta = currentTime - trade.time
                diagnostic.addSymbol(tsEvent.eventSymbol)
                diagnostic.addDeltas(delta)
            default: break
            }

        }
    }
}

extension LatencyViewController: UITableViewDataSource {
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

extension LatencyViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension LatencyViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField!) -> Bool {
        textField.endEditing(true)
        return true
    }
}
