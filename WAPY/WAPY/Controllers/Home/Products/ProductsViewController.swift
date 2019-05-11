//
//  ProductsViewController.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 11/05/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import UIKit

open class ProductsViewController: UIViewController{

    fileprivate var tableView: UITableView!
    internal lazy var remoteDelegate: ProductRemoteDelegate = ProductRemoteDelegate()
    internal lazy var remoteDataSource: ProductRemoteDataSource = ProductRemoteDataSource()

    open override func loadView() {
        super.loadView()
        self.view.backgroundColor = .white

        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])

        tableView.register(ProductItemCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = remoteDelegate
        tableView.dataSource = remoteDataSource
        tableView.remote.load()

        remoteDelegate.didSelectItem = { [unowned self] product in
            self.didSelectItem(product)
        }
    }

    /// called when user clicks one of the products in the table view.
    func didSelectItem(_ product: Product) {

    }

}
