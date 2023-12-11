//
//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import UIKit
import DXFeedFramework

class ViewController: UIViewController {
    private struct Command {
        let cmd: String
        let stdin: String
        let defaultParameter: String

        init(_ cmd: String, defaultParameter: String = "", stdin: String = "") {
            self.cmd = cmd
            self.defaultParameter = defaultParameter
            self.stdin = stdin
        }
    }

    @IBOutlet var consoleTextView: UITextView!
    @IBOutlet var cmdTextField: UITextField!
    @IBOutlet var argumentsTextField: UITextField!
    @IBOutlet var vmOptionsTextField: UITextField!
    @IBOutlet var stdIntextField: UITextField!

    @IBOutlet var hostnameLabel: UILabel!
    var pickerView = UIPickerView()

    let outPipe = Pipe()
    let errorPipe = Pipe()
    let inPipe = Pipe()
    private let commands = [Command("Compare"),
                            Command("Connect", defaultParameter: "iphone11.local:6666 Quote AAPL"),
                            Command("Dump"),
                            Command("Feed"),
                            Command("Forward"),
                            Command("FileAnalysis"),
                            Command("GCTimeTransformer"),
                            Command("Help"),
                            Command("Instruments"),
                            Command("Invoke"),
                            Command("Multiplexor"),
                            Command("NetTest", defaultParameter: "p :6666 -S 1 -c stream"),
                            Command("Post", defaultParameter: ":6666", stdin: "Quote AAPL 20240101-000000 1"),
                            Command("Services"),
                            Command("SchemeDump"),
                            Command("SubscriptionDumpParser"),
                            Command("TDP"),
                            Command("Time")]

    override func viewDidLoad() {
        super.viewDidLoad()
        hostnameLabel.text = "Host name: \(ProcessInfo.processInfo.hostName)"

        pickerView.translatesAutoresizingMaskIntoConstraints = false

        pickerView.dataSource = self
        pickerView.delegate = self
        cmdTextField.inputView = pickerView

        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "Execute", style: .plain, target: self, action: #selector(self.runCommand))
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        cmdTextField.inputAccessoryView = toolBar

        argumentsTextField.delegate = self
        vmOptionsTextField.delegate = self
        stdIntextField.delegate = self
        redirectStd()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let index = commands.lastIndex(where: { cmd in
            cmd.cmd.lowercased() == "post"
        }) {
            pickerView.selectRow(index, inComponent: 0, animated: false)
            self.pickerView(pickerView, didSelectRow: index, inComponent: 0)
            cmdTextField.becomeFirstResponder()
        }
    }

    @IBAction func runCommand() {
        view.endEditing(true)
        vmOptionsTextField.text?.components(separatedBy: ",").forEach({ str in
            let propertiesPair = str.components(separatedBy: "=")
            if propertiesPair.count == 2 {
                try? SystemProperty.setProperty(propertiesPair.first!, propertiesPair.last!)
            }
        })

        let cmdsStr = (cmdTextField.text ?? "") + " " + (argumentsTextField.text ?? "")
        let cmds = cmdsStr.components(separatedBy: " ")
        argumentsTextField.isEnabled = false
        vmOptionsTextField.isEnabled = false
        cmdTextField.isEnabled = false
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.3) {
            try? QdsUtils.execute(cmds)
        }
    }

    func redirectStd () {
        // redirect std out
        setvbuf(stdout, nil, _IONBF, 0)
        dup2(outPipe.fileHandleForWriting.fileDescriptor,
             STDOUT_FILENO)
        outPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            let str = String(data: data, encoding: .ascii) ?? "<Non-ascii data of size\(data.count)>\n"
            DispatchQueue.main.async {
                guard let strongSelf = self else {
                    return
                }
                strongSelf.publishText(str)
            }
        }

        // redirect std error
        setvbuf(stdout, nil, _IONBF, 0)
        dup2(errorPipe .fileHandleForWriting.fileDescriptor,
             STDERR_FILENO)
        errorPipe .fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            let str = String(data: data, encoding: .ascii) ?? "<Non-ascii data of size\(data.count)>\n"
            DispatchQueue.main.async {
                guard let strongSelf = self else {
                    return
                }
                strongSelf.publishText(str)
            }
        }

        // redirect std in
        setvbuf(stdout, nil, _IONBF, 0)
        dup2(inPipe.fileHandleForReading.fileDescriptor,
             STDIN_FILENO)
    }

    private func publishText(_ str: String) {
        if str.contains("Make a symbolic") || str.contains("UIView") || str.starts(with: "E ") {
            return
        }
        consoleTextView.text += str
        scrollTextViewToBottom(textView: consoleTextView)
    }

    func scrollTextViewToBottom(textView: UITextView) {
        if textView.text.count > 0 {
            let location = textView.text.count - 1
            let bottom = NSRange(location: location, length: 1)
            textView.scrollRangeToVisible(bottom)
        }
    }
}

extension ViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return commands.count
    }
}

extension ViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return commands[row].cmd
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        argumentsTextField.text = commands[row].defaultParameter
        cmdTextField.text = commands[row].cmd
        stdIntextField.text = commands[row].stdin
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == argumentsTextField ||
            textField == vmOptionsTextField {
            runCommand()
            textField.resignFirstResponder()
        } else {
            let fileHandleForWriting = inPipe.fileHandleForWriting

            let stringToWrite = (textField.text ?? "?") + "\n"

            if let dataToWrite = stringToWrite.data(using: .utf8) {
                fileHandleForWriting.write(dataToWrite)
            }
            textField.resignFirstResponder()
        }
        return true
    }
}
