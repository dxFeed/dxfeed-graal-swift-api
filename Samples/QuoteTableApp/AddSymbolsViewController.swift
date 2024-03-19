//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation
import UIKit
import DXFeedFramework

class AddSymbolsViewController: UIViewController {
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var symbolsTableView: UITableView!
    @IBOutlet var titleLabel: UILabel!

    var symbols = [String]()
    var selectedSymbols = Set<String>()
    var dataProvider = SymbolsDataProvider()

    override func viewDidLoad() {
        selectedSymbols = Set(dataProvider.selectedSymbols)
        symbols = dataProvider.allSymbols.sorted()

        titleLabel.textColor = .text

        symbolsTableView.backgroundColor = .tableBackground
        symbolsTableView.separatorStyle = .none

//        searchBar.searchTextField.textColor = .text
//        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
//            string: "Search symbol",
//            attributes: [.foregroundColor: UIColor.text!.withAlphaComponent(0.5)]
//        )
//        searchBar.barTintColor = .tableBackground
        super.viewDidLoad()
        view.backgroundColor = .tableBackground
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.readIpf()
        }
    }

    func readIpf() {
        let reader = DXInstrumentProfileReader()
        do {
            let result = try reader.readFromFile(address: "https://demo:demo@tools.dxfeed.com/ipf?TYPE=FOREX,STOCK&compression=zip")
            guard let result = result  else {
                return
            }
            let stocksData = result.map { ipf in
                return ipf.symbol
            }
            DispatchQueue.main.async {
                self.reloadData(symbols: stocksData)
            }
        } catch {
        }
    }

    @IBAction func cancelTouchUpInside(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func addTouchUpInside(_ sender: UIButton) {
        dataProvider.addSymbols(selectedSymbols)
        dataProvider.allSymbols = symbols
        self.navigationController?.popViewController(animated: true)
    }

    func reloadData(symbols: [String]) {
        self.symbols = symbols.sorted()
        symbolsTableView.reloadData()
    }
}

extension AddSymbolsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return symbols.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SymbolCellId", for: indexPath)
                as? SymbolCell else {
            return UITableViewCell()
        }
        let symbol = symbols[indexPath.row]
        cell.update(symbol: symbol, check: selectedSymbols.contains(symbol))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let symbol = symbols[indexPath.row]
        let checked = selectedSymbols.contains(symbol)
        if checked {
            selectedSymbols.remove(symbol)
        } else {
            selectedSymbols.insert(symbol)
        }
        tableView.reloadRows(at: [indexPath], with: .none)
        return indexPath
    }
}
