//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import UIKit

class SymbolCell: UITableViewCell {
    @IBOutlet var symbolNameLabel: UILabel!
    @IBOutlet var enabledSwitch: UISwitch?

    @IBOutlet var backgroundContentView: UIView!

    required init?(coder: NSCoder) {
        super.init(coder: coder)

    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .tableBackground
        self.symbolNameLabel.textColor = .text

        self.backgroundContentView.layer.cornerRadius = 10
        self.backgroundContentView.clipsToBounds = true
        self.contentView.backgroundColor = .tableBackground
        self.backgroundContentView.backgroundColor = .cellBackground
    }

    func update(symbol: String, check: Bool) {
        symbolNameLabel.text = symbol
        enabledSwitch?.isOn = check
    }

    
}
