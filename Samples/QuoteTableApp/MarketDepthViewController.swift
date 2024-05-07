//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import UIKit
import DXFeedFramework

class MarketDepthViewController: UIViewController {
    var feed: DXFeed!
    var symbol: String!

    var model: MarketDepthModel?

    @IBOutlet var connectButton: UIButton!
    @IBOutlet var sourcesTextField: UITextField!
    @IBOutlet var limitTextfield: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .tableBackground
        self.sourcesTextField.backgroundColor = .cellBackground
        self.sourcesTextField.placeholder = "Input sources splitted by ,"        
        self.sourcesTextField.textColor = .text
        self.limitTextfield.backgroundColor = .cellBackground
        self.limitTextfield.textColor = .text
        self.limitTextfield.placeholder = "Input limit"

        self.sourcesTextField.text = "ntv"
    }

    @IBAction func connectModel(_ sender: UIButton) {
        do {
            let sources = try sourcesTextField.text?.split(separator: ",").map { str in
                try OrderSource.valueOf(name: String(str))
            }

            if let sources = sources {
                model = try MarketDepthModel(symbol: symbol,
                                             sources: sources,
                                             mode: .multiple,
                                             feed: feed)
            }
        } catch {
            print("MarketDepthModel: \(error)")
        }
    }
}
