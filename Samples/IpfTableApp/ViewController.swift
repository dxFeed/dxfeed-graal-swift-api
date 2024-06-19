//
//  ViewController.swift
//  IpfTableApp
//
//  Created by Aleksey Kosylo on 07.09.23.
//

import UIKit
import DXFeedFramework

class ViewController: UIViewController {
    var collector: DXInstrumentProfileCollector?
    var connection: DXInstrumentProfileConnection?

    private var buffer = [String: InstrumentProfile]()
    private var ipfList = [InstrumentProfile]()

    @IBOutlet var ipfTableView: UITableView!
    @IBOutlet var lastUpdateLabel: UILabel!

    @IBOutlet var addressTextField: UITextField!

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addressTextField.text = "https://demo:demo@tools.dxfeed.com/ipf"
        view.backgroundColor = .tableBackground
        ipfTableView.backgroundColor = .tableBackground
        addressTextField.backgroundColor = .priceBackground
        addressTextField.textColor = .white
        addressTextField.layer.cornerRadius = 10
        addressTextField.clipsToBounds = true
        lastUpdateLabel.textColor = .white
        ipfTableView.estimatedRowHeight = 160
        ipfTableView.rowHeight = UITableView.automaticDimension
    }

    @IBAction func connectTapped(_ sender: Any) {
        collector = nil
        connection = nil
        do {
            collector = try DXInstrumentProfileCollector()
            connection = try DXInstrumentProfileConnection(addressTextField.text ?? "", collector!)
            // Update period can be used to re-read IPF files, not needed for services supporting IPF "live-update"
            try connection?.setUpdatePeriod(60000)
            connection?.add(observer: self)
            try collector?.add(observer: self)
            try connection?.start()
            // We can wait until we get first full snapshot of instrument profiles
            connection?.waitUntilCompleted(3000)
        } catch {
            print("Error during creation IPF data source: \(error)")
        }
    }
}

extension ViewController: DXInstrumentProfileConnectionObserver {
    func connectionDidChangeState(old: DXFeedFramework.DXInstrumentProfileConnectionState,
                                  new: DXFeedFramework.DXInstrumentProfileConnectionState) {
        print("\(CACurrentMediaTime()) connectionDidChangeState: \(new)")
    }
}

extension ViewController: DXInstrumentProfileUpdateListener {
    func instrumentProfilesUpdated(_ instruments: [DXFeedFramework.InstrumentProfile]) {
        instruments.forEach { ipf in
            if ipf.ipfType == .removed {
                self.buffer.removeValue(forKey: ipf.symbol)
            } else {
                self.buffer[ipf.symbol] = ipf
            }
        }
        DispatchQueue.main.async {
            self.lastUpdateLabel.text = TimeUtil.toLocalDateString(millis: self.collector?.getLastUpdateTime() ?? 0)
            self.ipfList = self.buffer.map { _, value in
                value
            }.sorted(by: { ipf1, ipf2 in
                ipf1.symbol < ipf2.symbol
            })
            self.ipfTableView.reloadData()
        }
    }
}

extension ViewController: UITableViewDataSource, UITabBarDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ipfList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "IpfCellId", for: indexPath)
                as? IpfCell else {
            return UITableViewCell()
        }
        let ipf = ipfList[indexPath.row]

        cell.update(title: ipf.symbol, value: ipf.descriptionStr + ipf.descriptionStr + ipf.descriptionStr)

        return cell
    }
}
