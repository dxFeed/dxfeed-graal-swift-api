//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation
import UIKit
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
        formatter.maximumFractionDigits = 4
        return formatter
    }()

    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var sizeLabel: UILabel!
    @IBOutlet var sizeContentView: UIView!
    @IBOutlet var sizeConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.priceLabel.textColor = .text
        self.sizeLabel.textColor = .text
        self.backgroundColor = .tableBackground
        sizeContentView.superview?.backgroundColor = .tableBackground
    }

    func update(price: Double,
                size: Double,
                maxSize: Double,
                isAsk: Bool) {
        priceLabel.text = formatter.string(from: NSNumber(value: price))
        sizeLabel.text = formatter.string(from: NSNumber(value: size))
        sizeContentView.backgroundColor = isAsk ? .green : .red
        let multiplier = min(size/maxSize, 1)
        let newConstraint = sizeConstraint.constraintWithMultiplier(multiplier)
        sizeContentView.superview?.removeConstraint(sizeConstraint)
        sizeContentView.superview?.addConstraint(newConstraint)
        self.layoutIfNeeded()
        sizeConstraint = newConstraint
    }
}
