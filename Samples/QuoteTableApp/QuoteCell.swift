//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import UIKit

class QuoteCell: UITableViewCell {
    @IBOutlet var symbolNameLabel: UILabel!
    @IBOutlet var askLabel: UILabel!
    @IBOutlet var bidLabel: UILabel!

    @IBOutlet var priceContentView: UIView!
    @IBOutlet var backgroundContentView: UIView!

    required init?(coder: NSCoder) {
        super.init(coder: coder)

    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.symbolNameLabel.textColor = .text
        self.askLabel.textColor = .text
        self.bidLabel.textColor = .text
        self.backgroundContentView.layer.cornerRadius = 10
        self.backgroundContentView.clipsToBounds = true
        self.contentView.backgroundColor = .clear
        self.backgroundContentView.backgroundColor = .cellBackground
        priceContentView.layer.cornerRadius = 10
        priceContentView.clipsToBounds = true
        priceContentView.backgroundColor = .clear
    }

    func updateAsk(value: Bool?) {
        updateLabelBackground(value: value, label: askLabel)
    }

    func updateBid(value: Bool?) {
        updateLabelBackground(value: value, label: bidLabel)
    }

    private func updateLabelBackground(value: Bool?, label: UILabel) {
        guard let value = value else {
            label.backgroundColor = .priceBackground
            return
        }
        label.backgroundColor = value ? .green : .red
    }

    func update(model: QuoteModel?, symbol: String, description: String?) {
        symbolNameLabel.text = symbol + "\n" + (description ?? "")
        askLabel.text = model?.ask
        updateAsk(value: model?.increaseAsk)
        updateBid(value: model?.increaseBid)
        bidLabel.text = model?.bid

    }
}
