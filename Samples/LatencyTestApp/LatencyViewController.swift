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

    @IBOutlet var connectionStatusLabel: UILabel!
    @IBOutlet var connectButton: UIButton!
    @IBOutlet var addressTextField: UITextField!

    @IBOutlet var rateOfEventsLabel: UILabel!
    @IBOutlet var rateOfEventsCounter: UILabel!

    @IBOutlet var rateOfUniqueSymbolsLabel: UILabel!
    @IBOutlet var rateOfUniqueSymbolsCounter: UILabel!

    @IBOutlet var numberOfEventsLabel: UILabel!
    @IBOutlet var numberOfEventsCounter: UILabel!

    @IBOutlet var currentCpuLabel: UILabel!
    @IBOutlet var currentCpuCounter: UILabel!

    @IBOutlet var peakCpuUsageLabel: UILabel!
    @IBOutlet var peakCpuUsageCounter: UILabel!

    @IBOutlet var resultTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        self.connectionStatusLabel.text = DXEndpointState.notConnected.convetToString()

        let font = UIFont.monospacedSystemFont(ofSize: 16.0, weight: .regular)
        resultTextView.font = font
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
  Rate of unique symbols   : --- (symbols/interval)
  Min                      : \(numberFormatter.string(from: metrics.min)!) (ms)
  Max                      : \(numberFormatter.string(from: metrics.max)!) (ms)
  99th percentile          : --- (ms)
  Mean                     : \(numberFormatter.string(from: metrics.mean)!) (ms)
  StdDev                   : --- (ms)
  Error                    : --- (ms)
  Sample size (N)          : --- (events)
  Measurement interval     : --- (s)
  Running time             : ---
"""
        resultTextView.text = result
        print(result)
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
    func receiveEvents(_ events: [DxFeedSwiftFramework.MarketEvent]) {
        let count = events.count
        let currentTime = UInt64(Date().timeIntervalSince1970 * 1_000)

        diagnostic.updateCounters(Int64(count))

        events.forEach { event in
            if event.type == .timeAndSale {

                var deltas = [UInt64]()
                if let tsEvent = event as? TimeAndSale {
                    let delta = currentTime - tsEvent.time
                    deltas.append(delta)
                    diagnostic.addDeltas(deltas)
                }

            }
        }

    }
}
