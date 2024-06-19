//
//  MetricCell.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 15.06.23.
//

import UIKit

class MetricCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var counterLabel: UILabel!
    @IBOutlet var backgroundContentView: UIView!


    let colors = Colors()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = colors.background

        self.backgroundContentView.backgroundColor = colors.cellBackground
        self.backgroundContentView.layer.cornerRadius = 10
        self.backgroundContentView.clipsToBounds = true
    }


    func update(title: String, value: String) {
        titleLabel.text = title
        counterLabel.text = value
    }
}
