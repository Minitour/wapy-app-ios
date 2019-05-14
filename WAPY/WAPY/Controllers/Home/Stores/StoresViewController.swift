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
    internal lazy var remoteDelegate = StoresRemoteDelegate()
    internal lazy var remoteDataSource = StoresRemoteDataSource()

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

        title = "Stores"
        navigationController?.navigationBar.prefersLargeTitles = true

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(didSelectAdd(_:)))

        remoteDelegate.didSelectItem = { [unowned self] item in
            let controller = StoreViewController()
            controller.store = item

            self.navigationController?.pushViewController(controller, animated: true)
        }
    }

    @objc func didSelectAdd(_ sender: UIBarButtonItem) {
        let controller = StoreCreateController()

        // set delegate

        let nav = UINavigationController(rootViewController: controller)

        present(nav, animated: true, completion: nil)
    }
}
