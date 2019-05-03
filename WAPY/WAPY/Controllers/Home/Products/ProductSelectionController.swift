//
//  ProductSelectionController.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 03/05/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import UIKit

public protocol ProductSelectionControllerDelegate: class {

    /// called when the product is selected
    func didSelectProduct(_ controller: ProductSelectionController, product: Product)

    /// called when cancel is selected
    func didCancelSelection(_ controller: ProductSelectionController)
}

public class ProductSelectionController: UIViewController{

    open weak var delegate: ProductSelectionControllerDelegate?

    fileprivate var tableView: UITableView!
    fileprivate lazy var remoteDelegate: ProductRemoteDelegate = ProductRemoteDelegate()
    fileprivate lazy var remoteDataSource: ProductRemoteDataSource = ProductRemoteDataSource()

    public override func loadView() {
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
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = remoteDelegate
        tableView.dataSource = remoteDataSource
        tableView.remote.load()

        remoteDelegate.didSelectItem = { [unowned self] product in
            self.delegate?.didSelectProduct(self, product: product)
        }

        navigationItem.rightBarButtonItem
            = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didSelectCancel(_:)))
    }

    @objc func didSelectCancel(_ sender: UIBarButtonItem) {
        delegate?.didCancelSelection(self)
    }


}
