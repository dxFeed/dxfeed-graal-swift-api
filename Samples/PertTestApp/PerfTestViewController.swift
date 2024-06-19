//
//  PerfTestViewController.swift
//  TestApp
//
//  Created by Aleksey Kosylo on 07.06.23.
//

import UIKit
import DxFeedSwiftFramework

class PerfTestViewController: UIViewController {
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

    @IBOutlet var rateOfListenersLabel: UILabel!
    @IBOutlet var rateOfListenersCounter: UILabel!

    @IBOutlet var numberOfEventsLabel: UILabel!
    @IBOutlet var numberOfEventsCounter: UILabel!

    @IBOutlet var currentCpuLabel: UILabel!
    @IBOutlet var currentCpuCounter: UILabel!

    @IBOutlet var peakCpuUsageLabel: UILabel!
    @IBOutlet var peakCpuUsageCounter: UILabel!

    let colors = Colors()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
        self.addressTextField.text = "localhost:6666"
        self.connectionStatusLabel.text = DXEndpointState.notConnected.convetToString()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0

        self.view.backgroundColor = colors.background

        try? SystemProperty.setProperty("com.devexperts.connector.proto.heartbeatTimeout", "10s")

        DispatchQueue.global(qos: .background).async {
                Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
                    self.updateUI()
                }
                RunLoop.current.run()
        }
    }

    func updateUI() {
        let metrics = diagnostic.getMetrics()
        diagnostic.updateCpuUsage()

        print("---------------------------------------------------")
        print("Event speed      \(numberFormatter.string(from: metrics.rateOfEvent)!) events/s")
        print("Listener Calls   \(numberFormatter.string(from: metrics.rateOfListeners)!) calls/s")
        DispatchQueue.main.async {
            self.rateOfEventsCounter.text = metrics.rateOfEvent.intValue > 1 ?
            "\(self.numberFormatter.string(from: metrics.rateOfEvent)!) events/s" : " "
            self.rateOfListenersCounter.text = metrics.rateOfListeners.intValue > 1 ?
            "\(self.numberFormatter.string(from: metrics.rateOfListeners)!) calls/s" : " "

            if metrics.rateOfEvent.intValue > 0 && metrics.rateOfListeners.intValue > 0 {
                let eventsIncall = metrics.rateOfEvent.doubleValue / metrics.rateOfListeners.doubleValue
                self.numberOfEventsCounter.text = eventsIncall > 1 ?
                "\(self.numberFormatter.string(from: NSNumber(value: eventsIncall))!) events" : " "
            } else {
                self.numberOfEventsCounter.text = " "
            }
            if metrics.rateOfEvent.intValue > 0 {
                self.currentCpuCounter.text = metrics.cpuUsage.intValue > 1 ?
                "\(self.numberFormatter.string(from: metrics.cpuUsage)!) %" : "0 %"
                self.peakCpuUsageCounter.text = metrics.peakCpuUsage.intValue > 1 ?
                "\(self.numberFormatter.string(from: metrics.peakCpuUsage)!) %" : "0 %"
            } else {
                self.currentCpuCounter.text = " "
                self.peakCpuUsageCounter.text = " "
            }
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
            profileSubscription = try? endpoint?.getFeed()?.createSubscription(.profile)
            subscription?.add(self)
            profileSubscription?.add(self)

            try? subscription?.addSymbols(symbols)
            try? profileSubscription?.addSymbols(symbols)
        }
    }
}

extension PerfTestViewController: DXEndpointObserver {
    func endpointDidChangeState(old: DxFeedSwiftFramework.DXEndpointState, new: DxFeedSwiftFramework.DXEndpointState) {
        DispatchQueue.main.async {
            self.isConnected = new == .connected
            self.updateConnectButton()

            self.connectionStatusLabel.text = new.convetToString()
        }
    }
}

extension PerfTestViewController: DXEventListener {
    func receiveEvents(_ events: [DxFeedSwiftFramework.MarketEvent]) {
        let count = events.count
        diagnostic.updateCounters(Int64(count))

        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            events.forEach { self.blackHoleInt ^= $0.eventTime }
        }
    }
}
