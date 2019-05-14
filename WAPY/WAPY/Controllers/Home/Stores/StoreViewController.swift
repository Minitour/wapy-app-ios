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
    }
}
