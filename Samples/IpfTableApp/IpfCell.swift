//
//  IpfCell.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 07.09.23.
//

import UIKit

class IpfCell: UITableViewCell {
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
        self.titleLabel.textColor = .white
        self.counterLabel.textColor = .white
    }

    func update(title: String, value: String) {
        titleLabel.text = title
        counterLabel.text = value
    }
}
