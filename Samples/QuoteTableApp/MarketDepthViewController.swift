//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import UIKit
import DXFeedFramework

class MarketDepthViewController: UIViewController {
    enum SectionIndex: Int {
        case buy = 1
        case sell = 0
    }

    private var endpoint: DXEndpoint!
    private var feed: DXFeed!
    var symbol: String!

    var model: MarketDepthModel?
    var orderBook = OrderBook()
    var maxValue: Double = 0

    @IBOutlet var connectButton: UIButton!
    @IBOutlet var sourcesTextField: UITextField!
    @IBOutlet var limitTextfield: UITextField!
    @IBOutlet var ordersTableView: UITableView!
    @IBOutlet var headerStackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()

        endpoint = try? DXEndpoint.create().connect("demo.dxfeed.com:7300")
        feed = endpoint?.getFeed()!

        self.ordersTableView.backgroundColor = .clear
//        self.ordersTableView.separatorStyle = .none        
        self.ordersTableView.register( UINib(nibName: "MarketDepthHeaderView", bundle: nil),
                                      forHeaderFooterViewReuseIdentifier: "MarketDepthHeaderView")
        if #available(iOS 15.0, *) {
            self.ordersTableView.sectionHeaderTopPadding = 5
        }
        self.view.backgroundColor = .tableBackground
        self.sourcesTextField.backgroundColor = .cellBackground
        self.sourcesTextField.placeholder = "Input sources splitted by ,"
        self.sourcesTextField.textColor = .text
        self.limitTextfield.backgroundColor = .cellBackground
        self.limitTextfield.textColor = .text
        self.limitTextfield.placeholder = "Input limit"
        self.limitTextfield.text = "5"

        self.limitTextfield.delegate = self
        self.sourcesTextField.delegate = self
//        self.sourcesTextField.text = "ntv"
    }

    @IBAction func connectModel(_ sender: UIButton) {
        do {
            let sources = try sourcesTextField.text?.split(separator: ",").map { str in
                try OrderSource.valueOf(name: String(str))
            }

            if let sources = sources {
                model = try MarketDepthModel(symbol: symbol,
                                             sources: sources,
                                             aggregationPeriodMillis: 0,
                                             mode: .multiple,
                                             feed: feed,
                                             listener: self)
                model?.setDepthLimit(Int(self.limitTextfield.text ?? "") ?? 0)
            }
        } catch {
            print("MarketDepthModel: \(error)")
        }
    }
}

extension MarketDepthViewController: MarketDepthListener {
    func modelChanged(changes: DXFeedFramework.OrderBook) {
        var maxValue: Double = 0
        changes.buyOrders.forEach { order in
            maxValue = max(maxValue, order.size)
        }
        changes.sellOrders.forEach { order in
            maxValue = max(maxValue, order.size)
        }

        DispatchQueue.main.async {
            self.maxValue = maxValue
            self.orderBook = changes
            self.headerStackView.isHidden = changes.buyOrders.count == 0 && changes.sellOrders.count == 0
            self.ordersTableView.reloadData()
        }
    }

}

extension MarketDepthViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
}

extension MarketDepthViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionIndex = SectionIndex(rawValue: section)
        switch sectionIndex {
        case .buy:
            return orderBook.buyOrders.count
        case .sell:
            return orderBook.sellOrders.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionIndex = SectionIndex(rawValue: indexPath.section)
        switch sectionIndex {
        case .buy:
            return buyCell(tableView, cellForRowAt: indexPath)
        case .sell:
            return sellCell(tableView, cellForRowAt: indexPath)
        default:
            return UITableViewCell()
        }
    }

    func buyCell(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath)
                as? OrderCell else {
            return UITableViewCell()
        }
        let order = orderBook.buyOrders[indexPath.row]
        cell.update(order: order,
                    maxSize: maxValue,
                    isBuy: true)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }

    func sellCell(_ tableView: UITableView,
                  cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath)
                as? OrderCell else {
            return UITableViewCell()
        }
        let order = orderBook.sellOrders[indexPath.row]
        cell.update(order: order,
                    maxSize: maxValue,
                    isBuy: false)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
}

extension MarketDepthViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         textField.resignFirstResponder()
        return true
    }
}
