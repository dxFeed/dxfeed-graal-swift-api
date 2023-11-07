//
//  SearchSymbolViewController.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 07.11.23.
//

import UIKit

class SearchSymbolViewController: UIViewController {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .tableBackground
        self.tableView.backgroundColor = .tableBackground
        self.closeButton.tintColor = .white
        self.addButton.tintColor = .white
        self.titleLabel.textColor = .white
    }
    @IBAction func close(_ sender: UISwitch) {
        navigationController?.popViewController(animated: true)
    }
}
