//
//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import UIKit
import DXFeedFramework
import ShowTouches

class ViewController: UIViewController {
    class TouchConfig {
        let touchColor: UIColor
        let circleSize: CGFloat
        let shortTapTresholdDuration: Double
        let shortTapInitialCircleRadius: CGFloat
        let shortTapFinalCircleRadius: CGFloat

        init(touchColor: UIColor, circleSize: CGFloat, shortTapTresholdDuration: Double, shortTapInitialCircleRadius: CGFloat, shortTapFinalCircleRadius: CGFloat) {
            self.touchColor = touchColor
            self.circleSize = circleSize
            self.shortTapTresholdDuration = shortTapTresholdDuration
            self.shortTapInitialCircleRadius = shortTapInitialCircleRadius
            self.shortTapFinalCircleRadius = shortTapFinalCircleRadius
        }

    }
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

    @IBOutlet var postBtn: UIButton!
    @IBOutlet var hostnameLabel: UILabel!
    var pickerView = UIPickerView()

    let outPipe = Pipe()
    let errorPipe = Pipe()
    let inPipe = Pipe()
    
    let config = TouchConfig(touchColor: UIView().tintColor.withAlphaComponent(0.6),
                                   circleSize: 40,
                                    shortTapTresholdDuration: 0.11,
                                   shortTapInitialCircleRadius: 12,
                                   shortTapFinalCircleRadius: 37)

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
                            Command("Post", defaultParameter: ":6666", stdin: "Quote AAPL 0 Q 0 0"),
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

    func performTouchInView(button: UIButton) {
        self.showExpandingCircle(at: CGPoint(x: button.bounds.midX, y: button.bounds.midY),
                                 //CGPoint(x: button.frame.width/2, y: button.frame.height/2),
                                 in: button)
        postCmd()
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

    @IBAction func postTap() {
        postCmd()
        var repeatCounter = 0

        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            repeatCounter += 1
            if repeatCounter <= 10 {
                self.performTouchInView(button: self.postBtn)
            }
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
        errorPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
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

    fileprivate func postCmd() {
        let fileHandleForWriting = inPipe.fileHandleForWriting

        let stringToWrite = stdIntextField.text ?? "?"
        if let dataToWrite = (stringToWrite + "\n").data(using: .utf8) {
            fileHandleForWriting.write(dataToWrite)
        }

        var symbols = stringToWrite.components(separatedBy: " ")
        if let lastSymbol = symbols.last {
            if var value = Int(lastSymbol) {
                value += 1
                symbols[symbols.endIndex - 1] = String(value)
            }
        }
        stdIntextField.text = symbols.joined(separator: " ")
        stdIntextField.resignFirstResponder()
    }

    func showExpandingCircle(at position: CGPoint, in view: UIView) {
        let circleLayer = CAShapeLayer()
        let initialRadius = config.shortTapInitialCircleRadius
        let finalRadius = config.shortTapFinalCircleRadius
        circleLayer.position = CGPoint(x: position.x - initialRadius, y: position.y - initialRadius)

        let startPathRect = CGRect(x: 0, y: 0, width: initialRadius * 2, height: initialRadius * 2)
        let startPath = UIBezierPath(roundedRect: startPathRect, cornerRadius: initialRadius)

        let endPathOrigin = initialRadius - finalRadius
        let endPathRect = CGRect(x: endPathOrigin, y: endPathOrigin, width: finalRadius * 2, height: finalRadius * 2)
        let endPath = UIBezierPath(roundedRect: endPathRect, cornerRadius: finalRadius)

        circleLayer.path = startPath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = config.touchColor.cgColor
        circleLayer.lineWidth = 2.0
        view.layer.addSublayer(circleLayer)

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            circleLayer.removeFromSuperlayer()
        }

        // Expanding animation
        let expandingAnimation = CABasicAnimation(keyPath: "path")
        expandingAnimation.fromValue = startPath.cgPath
        expandingAnimation.toValue = endPath.cgPath
        expandingAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        expandingAnimation.duration = 0.4
        expandingAnimation.repeatCount = 1.0
        circleLayer.add(expandingAnimation, forKey: "expandingAnimation")
        circleLayer.path = endPath.cgPath

        // Delayed fade out animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
            let fadingOutAnimation = CABasicAnimation(keyPath: "opacity")
            fadingOutAnimation.fromValue = 1.0
            fadingOutAnimation.toValue = 0.0
            fadingOutAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            fadingOutAnimation.duration = 0.15
            circleLayer.add(fadingOutAnimation, forKey: "fadeOutAnimation")
            circleLayer.opacity = 0.0
        }

        CATransaction.commit()
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
            postCmd()
        }
        return true
    }
}

