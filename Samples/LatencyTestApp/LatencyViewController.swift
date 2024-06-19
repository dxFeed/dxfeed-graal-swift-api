//
//  LatencyViewController.swift
//  LatencyTest
//
//  Created by Aleksey Kosylo on 14.06.23.
//

import UIKit
import DxFeedSwiftFramework

class LatencyViewController: UIViewController {
    let diagnostic = Diagnostic()

    let numberFormatter = NumberFormatter()

    private var endpoint: DXEndpoint?
    private var subscription: DXFeedSubcription?
    private var profileSubscription: DXFeedSubcription?

    var symbols = ["ETH/USD:GDAX"]
    var blackHoleInt: Int64 = 0

    var isConnected = false

    var dataSource = [String: String]()
    let soureTitles = ["Rate of events (avg)",
                      "Rate of unique symbols",
                      "Min",
                      "Max",
                      "99th percentile",
                      "Mean",
                      "StdDev",
                      "Error",
                      "Sample size (N)",
                      "Measurement interval",
                      "Running time"]

    @IBOutlet var connectionStatusLabel: UILabel!
    @IBOutlet var connectButton: UIButton!
    @IBOutlet var addressTextField: UITextField!

    @IBOutlet var resultTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .background
        resultTableView.backgroundColor = .background

        resultTableView.separatorStyle = .none

        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        self.connectionStatusLabel.text = DXEndpointState.notConnected.convetToString()

        addressTextField.text = "mddqa.in.devexperts.com:7400"
        DispatchQueue.global(qos: .background).async {
            Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
                self.updateUI()
            }
            RunLoop.current.run()
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
            endpoint?.add(self)
            try? endpoint?.connect(address)

            subscription = try? endpoint?.getFeed()?.createSubscription(.timeAndSale)
            subscription?.add(self)
            profileSubscription?.add(self)

            try? subscription?.addSymbols(symbols)
            try? profileSubscription?.addSymbols(symbols)
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
            "Rate of events (avg)": "\(numberFormatter.string(from: metrics.rateOfEvent)!) (events/s)",
            "Rate of unique symbols": "\(numberFormatter.string(from: metrics.rateOfSymbols)!) (symbols/interval)",
            "Min": "\(numberFormatter.string(from: metrics.min)!) (ms)",
            "Max": "\(numberFormatter.string(from: metrics.max)!) (ms)",
            "99th percentile": "\(numberFormatter.string(from: metrics.percentile)!) (ms)",
            "Mean": "\(numberFormatter.string(from: metrics.mean)!) (ms)",
            "StdDev": "\(numberFormatter.string(from: metrics.stdDev)!) (ms)",
            "Error": "\(numberFormatter.string(from: metrics.error)!) (ms)",
            "Sample size (N)": "\(numberFormatter.string(from: metrics.sampleSize)!) (events)",
            "Measurement interval": "\(numberFormatter.string(from: metrics.measureInterval)!) (s)",
            "Running time": "\(metrics.currentTime.stringFromTimeInterval())"
        ]
        self.resultTableView.reloadData()
    }
}

extension LatencyViewController: DXEndpointObserver {
    func endpointDidChangeState(old: DxFeedSwiftFramework.DXEndpointState, new: DxFeedSwiftFramework.DXEndpointState) {
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
