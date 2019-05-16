//
//  ConnectController.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 25/04/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import Foundation
import UIKit
import AZDialogView


public class ConnectController: UIViewController {

    lazy var service = CalibrationService.shared

    var networks: [Network] = []

    /// The current store object.
    var store: Store?

    /// The current camera object
    var camera: Camera?

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

        updateLabel(text: "Scanning...")

        service.onBluetoothAvailable = { service, err in
            // bluetooth became available.
            try? service.scan()
        }

        service.didDiscover = { [weak self] service, err in
            // did discover peripheral.
            guard let `self` = self else { return }
            self.updateLabel(text: "Connecting...")
            try? service.connect()

        }

        service.didConnect = {[weak self] service, err in
            guard let `self` = self else { return }
            // did sucessfully connect to the device.
            self.updateLabel(text: "Fetching Information...")
            DispatchQueue.main.async {
                self.getInfo(service: service)
            }
        }

        // scan if bluetooth is already available.
        if service.isBluetoothAvailable {
            try? service.scan()
        }

        navigationItem.leftBarButtonItem
            = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
    }


    /// Get the info data.
    ///
    /// - Parameter service: The calibartion service.
    func getInfo(service: CalibrationService) {
        service.getBoxInfo { [weak self](json) in
            guard let `self` = self else { return }

            guard let info = try? JSONDecoder().decode(CameraInfo.self, from: json.data(using: .utf8)!) else {
                //TODO: show error
                print("failed to parse info json")
                return
            }

            // trying to scan for a particular camera
            if info.calibrated, info.authenticated {

                guard let camera = self.camera,
                    info.id == camera.id else {
                    // disconnect if possible
                    service.disconnect()

                    self.showInvalidBoxDialog(name: info.name ?? "Unknown")
                    return
                }

                // we want to request an update.
                if info.isConnected {
                    // go directly to update controller because box already has wifi.
                    self.goToUpdateController()
                } else {
                    // go to wifi controller
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                        self.getAvailableWifi(service: service)
                    }
                }
            } else {
                // user not authenticated
                self.generateToken(service: service)
            }
        }
    }


    /// Callend to generate a token
    ///
    /// - Parameter service: The bluetooth service
    func generateToken(service: CalibrationService) {
        self.updateLabel(text: "Generating Token...")
        API.shared.generateToken { (token, err) in
            guard let token = token else {
                if let error = err { print(error) }
                return
            }

            self.updateLabel(text: "Updating Token...")
            self.updateToken(token: token, serivce: service)
        }
    }


    /// Called when it's time to update the token.
    ///
    /// - Parameters:
    ///   - token: The generated sign in token.
    ///   - serivce: The bluetooth service.
    func updateToken(token: String, serivce: CalibrationService) {
        service.updateToken(token) {[weak self]  service, err in
            guard let `self` = self else { return }
            self.updateLabel(text: "Scanning WiFi...")
            self.getAvailableWifi(service: service)
        }
    }


    /// Called when it's time to scan the wifi.
    ///
    /// - Parameter service: The bluetooth service.
    func getAvailableWifi(service: CalibrationService) {
        // finished updating token, get available wifis.
        service.getAvailableWifi { [weak self] jsonData in
            guard let `self` = self else { return }

            // parse json data
            let json = try? JSONSerialization.jsonObject(with: jsonData.data(using: .utf8)!, options: [])

            // get json as dicitionary
            guard let object = json as? [String: Any]  else { return }

            // get networks
            guard let networks = object["networks"] as? [Any] else { return }

            let jsonDecoder = JSONDecoder()

            // for each network in networks -> decode and put into self.networks
            for network in networks {
                guard let networkDict = network as? [String: Any] else { continue }

                let networkObj = try? jsonDecoder.decode(Network.self, from: networkDict.jsonStringRepresentation!.data(using: .utf8)!)
                if let networkObj = networkObj {
                    self.networks.append(networkObj)
                }
            }

            // continue to wifi selection
            self.goToSelectWifiController()
        }
    }

    /// Launches the wifi controller
    func goToSelectWifiController() {
        DispatchQueue.main.async {
            let selectNetworkController = SelectNetworkController()
            selectNetworkController.camera = self.camera
            selectNetworkController.store = self.store
            selectNetworkController.networks = self.networks
            self.navigationController?.pushViewController(selectNetworkController, animated: true)
        }
    }

    /// Launches the update/create controller
    func goToUpdateController() {
        DispatchQueue.main.async {
            let controller = CreateBoxController()
            controller.camera = self.camera
            controller.store = self.store
            controller.navigationItem.hidesBackButton = true
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }

    @objc func cancel() {
        service.disconnect()
        self.dismiss(animated: true, completion: nil)
    }

    func showInvalidBoxDialog(name: String) {
        let dialog = AZDialogViewController(title: "Error",
                                            message: "Attempting to connect to box \"\(name)\" which is already configured. If you own this box, go to your store, find it and select it from there in order to modify it.")
        dialog.buttonInit = GLOBAL_BUTTON_INIT
        dialog.buttonStyle = GLOBAL_STYLE
        dialog.dismissWithOutsideTouch = false
        dialog.dismissDirection = .none
        let tryAgain = AZDialogAction(title: "Scan Again") {[unowned self] dialog in
            dialog.dismiss(animated: true) {
                try? self.service.scan()
            }
        }

        let action = AZDialogAction(title: "Close") {[unowned self] dialog in
            dialog.dismiss(animated: false) {
                self.dismiss(animated: true, completion: nil)
            }
        }

        dialog.addAction(tryAgain)
        dialog.addAction(action)
        dialog.show(in: self)

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
