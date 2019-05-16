//
//  SelectNetworkController.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 25/04/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import UIKit
import AZDialogView

public class SelectNetworkController: UIViewController {
    
    lazy var service = CalibrationService.shared

    var networks: [Network]!
    var tableView: UITableView!

    var selectedNetwork: Network?

    var store: Store?
    var camera: Camera?

    public override func loadView() {
        super.loadView()

        self.navigationItem.hidesBackButton = true
        
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem
            = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))

        navigationItem.rightBarButtonItem
            = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(didSelectRefresh(_:)))
    }

    @objc func didSelectRefresh(_ sender: UIBarButtonItem) {
        service.getAvailableWifi { [weak self] jsonData in
            guard let `self` = self else { return }
            
            let json = try? JSONSerialization.jsonObject(with: jsonData.data(using: .utf8)!, options: [])
            guard let object = json as? [String: Any]  else { return }
            guard let networks = object["networks"] as? [Any] else { return }

            let jsonDecoder = JSONDecoder()
            self.networks.removeAll()
            for network in networks {
                guard let networkDict = network as? [String: Any] else { continue }


                do {
                let data = networkDict.jsonStringRepresentation!.data(using: .utf8)!
                let networkObj = try jsonDecoder.decode(Network.self, from: data)

                self.networks.append(networkObj)
                }catch {
                    print(error)
                }
            }

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    func connectToNetwork(_ network: Network) {

        // create textfield
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true

        // init dialog
        let dialog = AZDialogViewController(title: "Connect to WiFI", message: "What is the password for \(network.ssid!)?")
        dialog.buttonInit = GLOBAL_BUTTON_INIT
        dialog.buttonStyle = GLOBAL_STYLE
        dialog.customViewSizeRatio = 0.2

        // add textfield to container
        let container = dialog.container
        container.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            textField.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            textField.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])

        // add action
        let connect = AZDialogAction(title: "Connect") { [unowned self,unowned textField] dialog in

            // get network ssid
            let network = network.bssid!

            // get network password
            let password = textField.text

            // become loading dialog
            dialog.becomeLoadingDialog()

            // send data to update the network
            self.updateNetwork(dialog: dialog,
                               network: network,
                               password: password)

        }

        dialog.contentOffset = -60.0
        dialog.addAction(connect)
        dialog.show(in: self) { (dialog) in
            textField.becomeFirstResponder()
        }
    }

    @objc func cancel() {
        service.disconnect()
        self.dismiss(animated: true, completion: nil)
    }

    /// make BLE call to update the network
    func updateNetwork(dialog: AZDialogViewController, network: String, password: String?) {
        self.service.updateNetwork(bssid: network, password: password,secret: camera?.secret){ [weak self] service, err in
            guard let `self` = self else { return }
            if let err = err {
                print(err.localizedDescription)
                self.showWrongPasswordDialog(dialog: dialog, network: network)
            } else {
                self.goToCreateBoxController(dialog: dialog)
            }

        }
    }

    /// go to the box creation controller
    func goToCreateBoxController(dialog: AZDialogViewController) {
        DispatchQueue.main.async {
            dialog.dismiss(animated: true) {
                let createBoxController = CreateBoxController()
                createBoxController.camera = self.camera
                createBoxController.store = self.store
                self.navigationController?.pushViewController(createBoxController, animated: true)
            }
        }
    }

    func showWrongPasswordDialog(dialog: AZDialogViewController, network: String) {
        DispatchQueue.main.async {
            dialog.becomeErrorDialog(title: "Invalid Password",
                                     message: "The password that you submitted for \(network) is incorrect.",
                                     tryAgainMessage: "Try Again",
                                     tryAgainClosure: { [unowned self] in

                                        guard let network = self.selectedNetwork else { return }
                                        self.connectToNetwork(network)

            })
        }
    }
}

extension SelectNetworkController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let network = networks[indexPath.row]
        selectedNetwork = network
        connectToNetwork(network)
    }
}

extension SelectNetworkController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networks.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = networks[indexPath.row].ssid
        return cell
    }
}
