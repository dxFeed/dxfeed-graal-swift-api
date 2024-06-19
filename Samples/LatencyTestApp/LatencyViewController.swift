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
        resultTextView.text = result
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

        events.forEach { tsEvent in
            var deltas = [Int64]()
            let delta = currentTime - tsEvent.time
            deltas.append(delta)
            diagnostic.addSymbol(tsEvent.eventSymbol)
            diagnostic.addDeltas(deltas)
        }
    }
}

extension TimeInterval {
    func stringFromTimeInterval() -> String {
        let time = NSInteger(self)
        let miliseconds = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        return String(format: "%0.2d:%0.2d:%0.2d.%0.3d", hours, minutes, seconds, miliseconds)
    }
}
