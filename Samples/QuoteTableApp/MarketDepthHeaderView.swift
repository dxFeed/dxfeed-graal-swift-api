//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation
import UIKit

class MarketDepthHeaderView: UITableViewHeaderFooterView {
    @IBOutlet var titleLabel: UILabel!

    func setTitle(_ title: String, backgroundColor: UIColor) {
        titleLabel.text = title
        titleLabel.backgroundColor = backgroundColor
    }
}
