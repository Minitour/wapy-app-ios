//
//  StoreViewController.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 15/05/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import UIKit

public class StoreViewController: UIViewController {

    /// The id of the store.
    var store: Store!

    var tableView: UITableView!
    internal lazy var remoteDelegate = CameraRemoteDelegate(storeId: store.id!)
    internal lazy var remoteDataSource = CameraRemoteDataSource()

    public override func loadView() {
        super.loadView()

        tableView = UITableView()
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.register(CameraItemCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = remoteDelegate
        tableView.dataSource = remoteDataSource
        tableView.remote.load()

        title = store.name
        navigationController?.navigationBar.prefersLargeTitles = true

        navigationItem.rightBarButtonItem
            = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didSelectAdd(_:)))

        // add handler
        remoteDelegate.didSelectItem = { [unowned self] camera in
            self.didSelectCamera(camera)
        }
    }


    /// Called when user wishes to add a new camera to their store.
    ///
    @objc func didSelectAdd(_ sender: UIBarButtonItem) {
        let controller = ConnectController()
        let navController = FlexibleNavigationController(rootViewController: controller)
        self.present(navController, animated: true, completion: nil)
    }

    /// Called when user clicks a row
    func didSelectCamera(_ camera: Camera) {
        let controller = ConnectController()
        controller.camera = camera
        controller.store = self.store
        let navController = FlexibleNavigationController(rootViewController: controller)
        self.present(navController, animated: true, completion: nil)
    }
}
