//
//  ConnectController.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 25/04/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import Foundation
import UIKit



public class ConnectController: UIViewController {

    lazy var service = CalibrationService.shared

    var networks: [Network] = []

    var infoLabel: UILabel!

    public override func loadView() {
        super.loadView()
        view.backgroundColor = .white
        infoLabel = UILabel()

        view.addSubview(infoLabel)

        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

    }

    func updateLabel(text: String) {
        DispatchQueue.main.async {
            self.infoLabel.text = text
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)

        updateLabel(text: "Scanning...")

        service.onBluetoothAvailable = { service in
            // bluetooth became available.
            try? service.scan()
        }

        service.didDiscover = { [unowned self] service in
            // did discover peripheral.
            self.updateLabel(text: "Connecting...")
            try? service.connect()

        }

        service.didConnect = {[unowned self] service in
            // did sucessfully connect to the device.
            self.updateLabel(text: "Sending autherization token...")
            API.shared.generateToken { (token, err) in
                guard let token = token else {
                    print(err)
                    return
                }

                service.updateToken(token) {[unowned self]  (service) in
                    self.updateLabel(text: "Scanning WiFi...")

                    // finished updating token, get available wifis.
                    service.getAvailableWifi { [unowned self] jsonData in
                        let json = try? JSONSerialization.jsonObject(with: jsonData.data(using: .utf8)!, options: [])
                        guard let object = json as? [String: Any]  else { return }
                        guard let networks = object["networks"] as? [Any] else { return }

                        let jsonDecoder = JSONDecoder()
                        for network in networks {
                            guard let networkDict = network as? [String: Any] else { continue }

                            let networkObj = try? jsonDecoder.decode(Network.self, from: networkDict.jsonStringRepresentation!.data(using: .utf8)!)
                            if let networkObj = networkObj {
                                self.networks.append(networkObj)
                            }
                        }
                        self.next()
                    }
                }
            }
        }

        // scan if bluetooth is already available.
        if service.isBluetoothAvailable {
            try? service.scan()
        }
    }

    func next() {
        DispatchQueue.main.async {
            let selectNetworkController = SelectNetworkController()
            selectNetworkController.networks = self.networks
            self.navigationController?.pushViewController(selectNetworkController, animated: true)
        }
    }
}

extension Dictionary {
    var jsonStringRepresentation: String? {
        guard let theJSONData = try? JSONSerialization.data(withJSONObject: self,
                                                            options: [.prettyPrinted]) else {
                                                                return nil
        }
        return String(data: theJSONData, encoding: .utf8)
    }
}

extension Array {
    var jsonStringRepresentation: String? {
        guard let theJSONData = try? JSONSerialization.data(withJSONObject: self,
                                                            options: [.prettyPrinted]) else {
                                                                return nil
        }
        return String(data: theJSONData, encoding: .utf8)
    }
}
