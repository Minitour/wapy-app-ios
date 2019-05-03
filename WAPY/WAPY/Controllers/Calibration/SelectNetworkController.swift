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

    public override func loadView() {
        super.loadView()

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

        let navItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(didSelectRefresh(_:)))
        self.navigationItem.rightBarButtonItem = navItem
    }

    @objc func didSelectRefresh(_ sender: UIBarButtonItem) {
        service.getAvailableWifi { [unowned self] jsonData in
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
        // show a dialog to connect
        let dialog = AZDialogViewController(title: "Connect to WiFI", message: "What is the password for \(network.ssid!)?")
        let textField = UITextField()
        textField.isSecureTextEntry = true

        dialog.customViewSizeRatio = 0.2
        let container = dialog.container

        container.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            textField.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            textField.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])

        let connect = AZDialogAction(title: "Connect") { [unowned self,unowned textField] dialog in
            self.service.updateNetwork(bssid: network.bssid!,password: textField.text){ service in
                DispatchQueue.main.async {
                    dialog.dismiss(animated: true) {
                        let createBoxController = CreateBoxController()
                        self.navigationController?.pushViewController(createBoxController, animated: true)
                    }
                }
            }
        }

        dialog.contentOffset = -60.0

        dialog.addAction(connect)
        dialog.cancelEnabled = true
        dialog.cancelButtonStyle = {_,_ in true }
        dialog.show(in: self)
    }
}

extension SelectNetworkController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        connectToNetwork(networks[indexPath.row])
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
