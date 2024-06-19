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
    
    static let kSymbolsKey = "kSymbolsKey"
    var symbols: [String]? = nil
    var selectedSymbols = Set<String>()

    override func viewDidLoad() {
        reloadData()
        symbolsTableView.backgroundColor = .tableBackground
        symbolsTableView.separatorStyle = .none

        searchBar.searchTextField.textColor = .text
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search symbol",
            attributes: [.foregroundColor: UIColor.text!.withAlphaComponent(0.5)]
        )
        searchBar.barTintColor = .tableBackground
        super.viewDidLoad()
        view.backgroundColor = .tableBackground
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.global(qos: .background).async { 
//            [weak self] in
            self.readIpf()
        }
    }

    func readIpf() {
        let reader = DXInstrumentProfileReader()
        do {
            let result = try reader.readFromFile(address: "https://demo:demo@tools.dxfeed.com/ipf?compression=zip")
            guard let result = result  else {
                return
            }
            let stocksData = result.map { ipf in
                return ipf.symbol
            }
            DispatchQueue.main.async {
                self.saveLocalSymbols(symbols: stocksData)
                self.reloadData()
            }
            print(stocksData)
        } catch {
        }
    }

    @IBAction func cancelTouchUpInside(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    func reloadData() {
        symbols = loadLocalSymbols()?.sorted()
        symbolsTableView.reloadData()
    }
}

extension AddSymbolsViewController {
    func loadLocalSymbols() -> [String]? {
        UserDefaults.standard.value(forKey: AddSymbolsViewController.kSymbolsKey) as? [String]
    }

    func saveLocalSymbols(symbols: [String]) {
        if symbols.count > 0 {
            UserDefaults.standard.setValue(symbols, forKey: AddSymbolsViewController.kSymbolsKey)
        }
    }
}
extension AddSymbolsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return symbols?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SymbolCellId", for: indexPath)
                as? SymbolCell else {
            return UITableViewCell()
        }
        let symbol = symbols?[indexPath.row]
        let value = symbol ?? ""
        cell.update(symbol: value, check: selectedSymbols.contains(value))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {

        let symbol = symbols?[indexPath.row]
        let value = symbol ?? ""
        let checked = selectedSymbols.contains(value)
        if checked {
            selectedSymbols.remove(value)
        } else {
            selectedSymbols.insert(value)
        }
        tableView.reloadRows(at: [indexPath], with: .none)
        return indexPath
    }
}
