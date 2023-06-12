//
//  QuoteTableViewController.swift
//  TestApp
//
//  Created by Aleksey Kosylo on 07.06.23.
//

import UIKit
import DxFeedSwiftFramework

class QuoteTableViewController: UIViewController {
    private var endpoint: DXEndpoint?
    private var subscription: DXFeedSubcription?
    private var profileSubscription: DXFeedSubcription?

    var dataSource = [String: QuoteModel]()
    var symbols = ["AAPL", "IBM", "MSFT", "EUR/CAD", "ETH/USD:GDAX", "GOOG", "BAC", "CSCO", "ABCE", "INTC", "PFE"]

    @IBOutlet var quoteTableView: UITableView!
    @IBOutlet var connectionStatusLabel: UILabel!

    let colors = Colors()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = colors.background
        self.quoteTableView.backgroundColor = colors.background

        quoteTableView.separatorStyle = .none

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        try? SystemProperty.setProperty("com.devexperts.connector.proto.heartbeatTimeout", "10s")

        endpoint = try? DXEndpoint.builder().withRole(.feed)
            .withProperty(DXEndpoint.Property.aggregationPeriod.rawValue, "1")
            .build()
        endpoint?.add(self)
        try? endpoint?.connect("demo.dxfeed.com:7300")

        subscription = try? endpoint?.getFeed()?.createSubscription(.quote)
        profileSubscription = try? endpoint?.getFeed()?.createSubscription(.profile)
        subscription?.add(self)
        profileSubscription?.add(self)
        symbols.forEach {
            dataSource[$0] = QuoteModel()
        }
        try? subscription?.addSymbols(symbols)
        try? profileSubscription?.addSymbols(symbols)
    }
}

extension QuoteTableViewController: DXEndpointObserver {
    func endpointDidChangeState(old: DxFeedSwiftFramework.DXEndpointState, new: DxFeedSwiftFramework.DXEndpointState) {
        DispatchQueue.main.async {
            self.connectionStatusLabel.text = new.convetToString()
        }
    }
}

extension QuoteTableViewController: DXEventListener {
    func receiveEvents(_ events: [DxFeedSwiftFramework.MarketEvent]) {

        events.forEach { event in
            switch event.type {
            case .quote:
                if let quote = event as? Quote {
                    dataSource[event.eventSymbol]?.update(quote)
                }
            case .profile:
                if let profile = event as? Profile {
                    dataSource[event.eventSymbol]?.update(profile.descriptionStr)
                }
            default:
                print(event)
            }
        }
        DispatchQueue.main.async {
            self.quoteTableView.reloadData()
        }
    }
}

extension QuoteTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCellId", for: indexPath)
                as? QuoteCell else {
            return UITableViewCell()
        }
        let symbol = symbols[indexPath.row]
        let quote = dataSource[symbol]
        cell.update(model: quote, symbol: symbol, description: quote?.descriptionString)
        return cell
    }
}

extension QuoteTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
