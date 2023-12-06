//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import UIKit

class MetricCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var counterLabel: UILabel!
    @IBOutlet var backgroundContentView: UIView!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = .tableBackground
        self.backgroundContentView.backgroundColor = .cellBackground
        self.backgroundContentView.layer.cornerRadius = 10
        self.backgroundContentView.clipsToBounds = true
    }

    func update(title: String, value: String) {
        titleLabel.text = title
        counterLabel.text = value
    }
}
