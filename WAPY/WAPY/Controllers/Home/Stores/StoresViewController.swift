//
//  StoresViewController.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 13/04/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import UIKit

public class StoresViewController: UIViewController {

    var tableView: UITableView!
    fileprivate lazy var remoteDelegate = StoresRemoteDelegate()
    fileprivate lazy var remoteDataSource = StoresRemoteDataSource()

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

        tableView.register(StoreItemCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = remoteDelegate
        tableView.dataSource = remoteDataSource
        tableView.remote.load()
    }
}
