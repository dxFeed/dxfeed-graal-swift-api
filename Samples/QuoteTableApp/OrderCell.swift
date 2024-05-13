//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation
import UIKit
import DXFeedFramework

extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!,
                                  attribute: self.firstAttribute,
                                  relatedBy: self.relation,
                                  toItem: self.secondItem,
                                  attribute: self.secondAttribute,
                                  multiplier: multiplier,
                                  constant: self.constant)
    }
}

class OrderCell: UITableViewCell {
    lazy var formatter: NumberFormatter =
    {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 8
        return formatter
    }()

    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var sizeLabel: UILabel!
    @IBOutlet var sizeContentView: UIView!
    @IBOutlet var sizeConstraint: NSLayoutConstraint!
    @IBOutlet var infoLabel: UILabel!
    static let redBarColor = UIColor.red.withAlphaComponent(0.3)
    static let greenBarColor = UIColor.green.withAlphaComponent(0.3)

    override func awakeFromNib() {
        super.awakeFromNib()

        self.priceLabel.textColor = .text
        self.sizeLabel.textColor = .text
        self.backgroundColor = .tableBackground
        sizeContentView.superview?.backgroundColor = .tableBackground        
    }

    func update(order: Order, 
                maxSize: Double,
                isAsk: Bool) {
        let price = order.price
        let size = order.size
        let marketMaker = order.marketMaker
        let source = order.eventSource
        let scope = order.scope

        priceLabel.text = formatter.string(from: NSNumber(value: price))
        sizeLabel.text = formatter.string(from: NSNumber(value: size))
        sizeContentView.backgroundColor = isAsk ?OrderCell.greenBarColor : OrderCell.redBarColor
        sizeLabel.textColor = isAsk ? .green : .red
        var multiplier = min(size/maxSize, 1)
        if !multiplier.isFinite {
            multiplier = 0
        }
        let newConstraint = sizeConstraint.constraintWithMultiplier(multiplier)
        sizeContentView.superview?.removeConstraint(sizeConstraint)
        sizeContentView.superview?.addConstraint(newConstraint)
        self.layoutIfNeeded()
        sizeConstraint = newConstraint

        infoLabel.text = "\(source.toString()) \(scope) \(marketMaker ?? "")"
    }
}
