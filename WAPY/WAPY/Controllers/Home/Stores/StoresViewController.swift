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
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
    }
}
