//
//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import UIKit
import DXFeedFramework

class ViewController: UIViewController {
    @IBOutlet var consoleTextView: UITextView!
    @IBOutlet var commandTextField: UITextField!
    @IBOutlet var recordTextField: UITextField!
    @IBOutlet var propertiesTextField: UITextField!

    var pipe = Pipe()

    override func viewDidLoad() {
        super.viewDidLoad()
        openConsolePipe()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }

    @IBAction func runCommand(_ sender: UISwitch) {
        view.endEditing(true)
        try? SystemProperty.setProperty("com.devexperts.qd.tools.NetTest.record", recordTextField.text ?? "")
        propertiesTextField.text?.components(separatedBy: ",").forEach({ str in
            let propertiesPair = str.components(separatedBy: "=")
            if propertiesPair.count == 2 {
                try? SystemProperty.setProperty(propertiesPair.first!, propertiesPair.last!)
            }
        })
        let cmds = self.commandTextField.text?.components(separatedBy: " ") ?? [""]
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.3) {
            try? QdsUtils.execute(cmds)
        }
    }

    func openConsolePipe () {
        setvbuf(stdout, nil, _IONBF, 0)
        dup2(pipe.fileHandleForWriting.fileDescriptor,
             STDERR_FILENO)
        // listening on the readabilityHandler
        pipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            let str = String(data: data, encoding: .ascii) ?? "<Non-ascii data of size\(data.count)>\n"
            DispatchQueue.main.async {
                guard let strongSelf = self else {
                    return
                }
                strongSelf.consoleTextView.text += str
                strongSelf.scrollTextViewToBottom(textView: strongSelf.consoleTextView)
            }
        }
    }

    func scrollTextViewToBottom(textView: UITextView) {
        if textView.text.count > 0 {
            let location = textView.text.count - 1
            let bottom = NSRange(location: location, length: 1)
            textView.scrollRangeToVisible(bottom)
        }
    }
}
