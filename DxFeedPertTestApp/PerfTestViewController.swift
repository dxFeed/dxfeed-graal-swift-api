//
//  PerfTestViewController.swift
//  TestApp
//
//  Created by Aleksey Kosylo on 07.06.23.
//

import UIKit
import DxFeedSwiftFramework

class Counter {
    private (set) var value: Int64 = 0
    func add (_ amount: Int64) {
        OSAtomicAdd64(amount, &value)
    }
}

struct Colors {
    let background = UIColor(red: 18/255, green: 16/255, blue: 49/255, alpha: 1.0)
    let cellBackground = UIColor(red: 31/255, green: 30/255, blue: 65/255, alpha: 1.0)

    let priceBackground = UIColor(red: 60/255, green: 62/255, blue: 101/255, alpha: 1.0)
    let green = UIColor(red: 0/255, green: 117/255, blue: 91/255, alpha: 1.0)
    let red = UIColor(red: 147/255, green: 0/255, blue: 36/255, alpha: 1.0)
}

class PerfTestViewController: UIViewController {
    var counter = Counter()
    var counterListener = Counter()

    let numberFormatter = NumberFormatter()
    var startTime = Date.now
    var lastValue: Int64 = 0
    var lastListenerValue: Int64 = 0

    private var endpoint: DXEndpoint?
    private var subscription: DXFeedSubcription?
    private var profileSubscription: DXFeedSubcription?

    var symbols = ["ETH/USD:GDAX"]
    var blackHoleInt: Int64 = 0

    var isConnected = false

    @IBOutlet var connectionStatusLabel: UILabel!
    @IBOutlet var eventsCounterLabel: UILabel!
    @IBOutlet var connectButton: UIButton!
    @IBOutlet var addressTextField: UITextField!

    let colors = Colors()

    override func viewDidLoad() {
        super.viewDidLoad()
        numberFormatter.numberStyle = .decimal

        self.view.backgroundColor = colors.background

        try? SystemProperty.setProperty("com.devexperts.connector.proto.heartbeatTimeout", "10s")

        DispatchQueue.global(qos: .background).async {
                Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
                    let lastStart = self.startTime
                    let currentValue = self.counter.value
                    let currentListenerValue = self.counterListener.value

                    self.startTime = Date.now
                    let seconds = Date.now.timeIntervalSince(lastStart)
                    let speed = seconds == 0 ? nil : NSNumber(value: Double(currentValue - self.lastValue) / seconds)

                    let speedListener = NSNumber(value: Double(currentListenerValue - self.lastListenerValue) / seconds)

                    self.lastValue = currentValue
                    self.lastListenerValue = currentListenerValue

                    if let speed = speed {
                        print("---------------------------------------------------")
                        print("Event speed      \(self.numberFormatter.string(from: speed)!) events/s")
                        print("Listener Calls   \(self.numberFormatter.string(from: speedListener)!) calls/s")

                        DispatchQueue.main.async {
                            self.eventsCounterLabel.text =
                            "Event speed: \(self.numberFormatter.string(from: speed)!) events/s"
                        }
                    }
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
            endpoint = try? DXEndpoint.builder().withRole(.feed).build()
            endpoint?.add(self)
            try? endpoint?.connect("localhost:6666")

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
        counter.add(Int64(count))
        counterListener.add(1)

        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            events.forEach { self.blackHoleInt ^= $0.eventTime }
        }
    }
}
