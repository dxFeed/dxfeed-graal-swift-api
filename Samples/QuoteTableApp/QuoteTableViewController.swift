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
        self.quoteTableView.separatorStyle = .none

        var attText = AttributedString.init("Learn more about dxFeed APIs")
        attText.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        var configuration = UIButton.Configuration.plain()
        configuration.imagePadding = 5
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        configuration.attributedTitle = attText
        configuration.buttonSize = .mini
        noticeButton.configuration = configuration

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
        }

        subscription = try? endpoint?.getFeed()?.createSubscription(Quote.self, Profile.self)

        try? subscription?.add(listener: self)

        symbols.forEach {
            dataSource[$0] = QuoteModel()
        }
        try? subscription?.addSymbols(symbols)
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
        let symbol = self.symbols[indexPath.row]

        let alert = UIAlertController(title: symbol, message: "", preferredStyle: .actionSheet)
        let candlesAction = UIAlertAction(title: "Candle Chart", style: .default) { _ in
            let ipfAddress = "https://demo:demo@tools.dxfeed.com/ipf?SYMBOL="
            let candleChartViewController = MyUIHostingController(rootView: CandleChart(symbol: symbol,
                                                                                        type: .day,
                                                                                        endpoint: self.endpoint,
                                                                                        ipfAddress: ipfAddress))
            candleChartViewController.title = symbol
            self.navigationController?.pushViewController(candleChartViewController, animated: true)
        }
        alert.addAction(candlesAction)

        let marketDepthAction = UIAlertAction(title: "Depth Of Market", style: .default) { _ in
            let storyboard = UIStoryboard(name: "MainMarketDepth", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "MarketDepthViewController")
            if let marketDepthViewController = viewController as? MarketDepthViewController {
                marketDepthViewController.symbol = symbol
                marketDepthViewController.title = symbol
                self.navigationController?.pushViewController(marketDepthViewController, animated: true)
            }
        }
        alert.addAction(marketDepthAction)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) {_ in })
        let cell = tableView.cellForRow(at: indexPath)

        alert.popoverPresentationController?.sourceView = self.quoteTableView
        alert.popoverPresentationController?.sourceRect = cell?.frame ?? CGRect(x: 0, y: 0, width: 50, height: 50)

        self.present(alert, animated: true, completion: nil)

    }
}

extension QuoteTableViewController: UIGestureRecognizerDelegate {
    // swipe to back
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

class MyUIHostingController<Content>: UIHostingController<Content> where Content: View {
    override func viewDidLoad() {
        super.viewDidLoad()
        // fix for datepicker selected color
        overrideUserInterfaceStyle = .dark
    }
}
