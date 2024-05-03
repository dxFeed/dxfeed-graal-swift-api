//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import UIKit
import DXFeedFramework
import SwiftUI

class QuoteTableViewController: UIViewController {
    private var endpoint: DXEndpoint?
    private var subscription: DXFeedSubscription?
    private var profileSubscription: DXFeedSubscription?

    var dataSource = [String: QuoteModel]()
    var symbols = [String]()
    let dataProvider = SymbolsDataProvider()

    @IBOutlet var quoteTableView: UITableView!
    @IBOutlet var agregationSwitch: UISwitch!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var noticeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.view.backgroundColor = .tableBackground
        self.quoteTableView.backgroundColor = .clear

        quoteTableView.separatorStyle = .none
        
        noticeButton.setTitle("Learn more about dxFeed APIs", for: .normal)
        noticeButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)

        NotificationCenter.default.addObserver(forName: .selectedSymbolsChanged,
                                               object: nil,
                                               queue: nil) { [weak self] (_) in
            guard let strongSelf = self else {
                return
            }

            strongSelf.loadQuotes()
        }
        loadQuotes()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    func loadQuotes() {
        let newSymbols = dataProvider.selectedSymbols
        if symbols != newSymbols {
            symbols = newSymbols
            dataSource.removeAll()
            symbols.forEach {
                dataSource[$0] = QuoteModel()
            }
            quoteTableView.reloadData()
            self.subscribe(false)
        }
    }

    func subscribe(_ unlimited: Bool) {
        if endpoint == nil {
            try? SystemProperty.setProperty(DXEndpoint.ExtraProperty.heartBeatTimeout.rawValue, "15s")

            let builder = try? DXEndpoint.builder().withRole(.feed)
            if !unlimited {
                _ = try? builder?.withProperty(DXEndpoint.Property.aggregationPeriod.rawValue, "1")
            }
            endpoint = try? builder?.build()
            endpoint?.add(listener: self)
            _ = try? endpoint?.connect("demo.dxfeed.com:7300")
        } else {
            subscription = nil
            profileSubscription = nil
        }

        subscription = try? endpoint?.getFeed()?.createSubscription(Quote.self)
        profileSubscription = try? endpoint?.getFeed()?.createSubscription(Profile.self)
        try? subscription?.add(listener: self)
        try? profileSubscription?.add(listener: self)
        symbols.forEach {
            dataSource[$0] = QuoteModel()
        }
        try? subscription?.addSymbols(symbols)
        try? profileSubscription?.addSymbols(symbols)

    }

    @IBAction func changeAggregationPeriod(_ sender: UISwitch) {
        subscribe(agregationSwitch.isOn)
    }

    @IBAction func openNews(_ sender: UIButton) {
        let url = URL(string: "https://dxfeed.com/dxfeed-news/")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(url)
        }
    }
}

extension QuoteTableViewController: DXEndpointListener {
    func endpointDidChangeState(old: DXEndpointState, new: DXEndpointState) {

    }
}

extension QuoteTableViewController: DXEventListener {
    func receiveEvents(_ events: [MarketEvent]) {
        events.forEach { event in
            switch event.type {
            case .quote:
                dataSource[event.eventSymbol]?.update(event.quote)
            case .profile:
                dataSource[event.eventSymbol]?.update(event.profile.descriptionStr ?? "")
            default: break
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
        cell.selectionStyle = .none

        return cell
    }
}

extension QuoteTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let symbol = symbols[indexPath.row]
        let candleChartViewController = MyUIHostingController(rootView: CandleStickChart(symbol: symbol, 
                                                                                         type: .week,
                                                                                         endpoint: endpoint))
        candleChartViewController.title = symbol
        self.navigationController?.pushViewController(candleChartViewController, animated: true)
    }
}

extension QuoteTableViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

class MyUIHostingController<Content>: UIHostingController<Content> where Content : View {
    override func viewDidLoad() {
        super.viewDidLoad()
        // fix for datepicker selected color
        overrideUserInterfaceStyle = .dark
    }
}
