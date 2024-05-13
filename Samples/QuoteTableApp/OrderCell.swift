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
    @IBOutlet var sizeBuyLabel: UILabel!
    @IBOutlet var sizeSellLabel: UILabel!

    @IBOutlet var sizeBuyContentView: UIView!
    @IBOutlet var sizeSellContentView: UIView!

    @IBOutlet var sizeBuyConstraint: NSLayoutConstraint!
    @IBOutlet var sizeSellConstraint: NSLayoutConstraint!

    static let redBarColor = UIColor.red.withAlphaComponent(0.3)
    static let greenBarColor = UIColor.green.withAlphaComponent(0.3)

    override func awakeFromNib() {
        super.awakeFromNib()

        self.priceLabel.textColor = .text

        sizeBuyLabel.textColor = .text
        sizeSellLabel.textColor = .text

        self.backgroundColor = .tableBackground
        sizeBuyContentView.superview?.backgroundColor = .tableBackground
        sizeSellContentView.superview?.backgroundColor = .tableBackground
    }

    func update(order: Order, 
                maxSize: Double,
                isBuy: Bool) {
        let price = order.price
        let size = order.size
        let marketMaker = order.marketMaker
        let source = order.eventSource
        let scope = order.scope

        priceLabel.text = formatter.string(from: NSNumber(value: price))

        sizeBuyLabel.text = formatter.string(from: NSNumber(value: size))
        sizeBuyLabel.textColor = isBuy ? .green : .red
       
        sizeSellLabel.text = formatter.string(from: NSNumber(value: size))
        sizeSellLabel.textColor = isBuy ? .green : .red

        sizeBuyContentView.backgroundColor = isBuy ?OrderCell.greenBarColor : OrderCell.redBarColor
        sizeSellContentView.backgroundColor = isBuy ?OrderCell.greenBarColor : OrderCell.redBarColor

        var multiplier = min(size/maxSize, 1)
        if !multiplier.isFinite {
            multiplier = 0
        }
        update(constraint: &sizeBuyConstraint, multiplier: multiplier, on: sizeBuyContentView)
        update(constraint: &sizeSellConstraint, multiplier: multiplier, on: sizeSellContentView)

        sizeBuyLabel.isHidden = !isBuy
        sizeSellLabel.isHidden = isBuy

        sizeBuyContentView.isHidden  = !isBuy
        sizeSellContentView.isHidden  = isBuy
    }
    
    private func update(constraint: inout NSLayoutConstraint, multiplier: Double, on view: UIView) {
        let newConstraint = constraint.constraintWithMultiplier(multiplier)
        view.superview?.removeConstraint(constraint)
        view.superview?.addConstraint(newConstraint)
        self.layoutIfNeeded()
        constraint = newConstraint
    }
}
