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
    @IBOutlet var symbolsTableView: UITableView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    var symbols = [InstrumentInfo]()
    var selectedSymbols = Set<String>()
    var dataProvider = SymbolsDataProvider()


    override func viewDidLoad() {
        super.viewDidLoad()
        selectedSymbols = Set(dataProvider.selectedSymbols)
        symbols = dataProvider.allSymbols.sorted()
        changeActivityIndicator()

        symbolsTableView.backgroundColor = .tableBackground
        symbolsTableView.separatorStyle = .none

        view.backgroundColor = .tableBackground
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.readIpf()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dataProvider.addSymbols(selectedSymbols)
        dataProvider.allSymbols = symbols
    }


    func changeActivityIndicator() {
        if symbols.count == 0 {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        } else {
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        }
    }

    func readIpf() {
        let reader = DXInstrumentProfileReader()
        do {
            let result =
            try reader.readFromFile(address: "https://demo:demo@tools.dxfeed.com/ipf?TYPE=FOREX,STOCK&compression=zip")
            guard let result = result  else {
                return
            }
            let stocksData = result.map { ipf in
                let info = InstrumentInfo(symbol: ipf.symbol, descriptionStr: ipf.descriptionStr)
                return info
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

    func reloadData(symbols: [InstrumentInfo]) {
        self.symbols = symbols.sorted()
        changeActivityIndicator()
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
        cell.update(symbol: symbol.symbol + "\n" + symbol.descriptionStr,
                    check: selectedSymbols.contains(symbol.symbol))
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let symbol = symbols[indexPath.row]
        let checked = selectedSymbols.contains(symbol.symbol)
        if checked {
            selectedSymbols.remove(symbol.symbol)
        } else {
            selectedSymbols.insert(symbol.symbol)
        }
        tableView.reloadRows(at: [indexPath], with: .none)
        return indexPath
    }
}
