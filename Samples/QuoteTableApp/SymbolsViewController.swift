//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation
import UIKit

class SymbolsViewController: UIViewController {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var symbolsTableView: UITableView!

    var dataProvider = SymbolsDataProvider()
    var symbols = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        symbolsTableView.setEditing(true, animated: false)
        symbolsTableView.backgroundColor = .tableBackground
        symbolsTableView.separatorStyle = .none
        titleLabel.textColor = .text
        view.backgroundColor = .tableBackground
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        symbols = dataProvider.selectedSymbols
        symbolsTableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dataProvider.changeSymbols(symbols)
    }

    @IBAction func cancelTouchUpInside(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SymbolsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return symbols.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SymbolCellId", for: indexPath)
                as? SymbolCell else {
            return UITableViewCell()
        }
        let symbol = symbols[indexPath.row]
        cell.selectionStyle = .none
        cell.update(symbol: symbol, check: false)
        cell.overrideUserInterfaceStyle = .dark
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            symbols.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let rowToMove = symbols[sourceIndexPath.row]
        symbols.remove(at: sourceIndexPath.row)
        symbols.insert(rowToMove, at: destinationIndexPath.row)
    }
}
