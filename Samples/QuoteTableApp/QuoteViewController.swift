//
//  ViewController.swift
//  TestApp
//
//  Created by Aleksey Kosylo on 05.06.23.
//

import UIKit
import DXFeedFramework

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
    func endpointDidChangeState(old: DXEndpointState, new: DXEndpointState) {
        isConnected = new == .connected
        updateConnectButton()
    }
}

extension QuoteViewController: DXEventListener {
    func receiveEvents(_ events: [MarketEvent]) {
        DispatchQueue.main.async {
            self.eventsTextView.text = events.description
        }
    }
}
