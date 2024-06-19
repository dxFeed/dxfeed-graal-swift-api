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

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.textColor = .text
        view.backgroundColor = .tableBackground
    }

    @IBAction func cancelTouchUpInside(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func addSymbols(_ sender: UIButton) {
        if let newView = self.storyboard?.instantiateViewController(withIdentifier: "AddSymbolsViewController") as? AddSymbolsViewController {
            self.navigationController?.pushViewController(newView, animated: true)
        }
    }

}
