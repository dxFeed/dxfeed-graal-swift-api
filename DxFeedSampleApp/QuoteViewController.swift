//
//  ViewController.swift
//  TestApp
//
//  Created by Aleksey Kosylo on 05.06.23.
//

import UIKit
import DxFeedSwiftFramework

struct Colors {
    let background = UIColor(red: 18/255, green: 16/255, blue: 49/255, alpha: 1.0)
    let cellBackground = UIColor(red: 31/255, green: 30/255, blue: 65/255, alpha: 1.0)

    let priceBackground = UIColor(red: 60/255, green: 62/255, blue: 101/255, alpha: 1.0)
    let green = UIColor(red: 0/255, green: 117/255, blue: 91/255, alpha: 1.0)
    let red = UIColor(red: 147/255, green: 0/255, blue: 36/255, alpha: 1.0)
}

class QuoteViewController: UIViewController {
    private var endpoint: DXEndpoint?
    private var subscription: DXFeedSubcription?

    @IBOutlet var connectButton: UIButton!
    @IBOutlet var addressTextField: UITextField!
    @IBOutlet var subscribeButton: UIButton!
    @IBOutlet var symbolTextField: UITextField!
    @IBOutlet var eventsTextView: UITextView!

    var isConnected = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func updateConnectButton() {
        DispatchQueue.main.async {
            self.connectButton.setTitle(self.isConnected ? "Disconnect" : "Connect", for: .normal)
        }
    }

    @IBAction func connectTapped(_ sender: Any) {
        if isConnected {
            try? endpoint?.disconnect()
            subscription = nil
            eventsTextView.text = ""
            return
        }
        guard let address = addressTextField.text else {
            let alert = UIAlertController(title: "Error",
                                          message: "Please, input address",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        if endpoint == nil {
            endpoint = try? DXEndpoint.builder().withRole(.feed).build()
            endpoint?.add(self)
        }
        try? endpoint?.connect(address)
    }

    @IBAction func subscribeTapped(_ sender: Any) {
        if !isConnected {
            let alert = UIAlertController(title: "Error",
                                          message: "Please, connect before subscribe",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        guard let symbol = symbolTextField.text else {
            return
        }
        symbolTextField.resignFirstResponder()

        subscription = try? endpoint?.getFeed()?.createSubscription(.timeAndSale)
        subscription?.add(self)
        try? subscription?.addSymbols(symbol)
    }
}

extension QuoteViewController: DXEndpointObserver {
    func endpointDidChangeState(old: DxFeedSwiftFramework.DXEndpointState, new: DxFeedSwiftFramework.DXEndpointState) {
        isConnected = new == .connected
        updateConnectButton()
    }
}

extension QuoteViewController: DXEventListener {
    func receiveEvents(_ events: [DxFeedSwiftFramework.MarketEvent]) {
        DispatchQueue.main.async {
            self.eventsTextView.text = events.description
        }
    }
}
