//
//  ProductRemoteDelegate.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 03/05/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import AZRemoteTable
import UIKit

public class ProductRemoteDelegate: AZRemoteTableDelegate {
    var didSelectItem: ((Product) -> Void)?

    var dataSource: ProductRemoteDataSource? {
        return self.tableView?.remote.dataSource as? ProductRemoteDataSource
    }

    public override func tableView(_ tableView: UITableView, didRequestPage page: Int, usingRefreshControl: Bool = false) {
        let fakeResponse = [
            Product(id: "1", name: "my first product", image: nil),
            Product(id: "2", name: "my second product", image: nil),
            Product(id: "3", name: "my third product", image: nil)
        ]

        if usingRefreshControl {
            dataSource?.clearItems()
        }

        dataSource?.addItems(items: fakeResponse)

        tableView.remote.notifySuccess(hasMore: false)
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let product = dataSource?.data[indexPath.row] else { return }
        didSelectItem?(product)
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0
    }
}
