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

        API.shared.getProducts { [unowned self] (products, error) in
            if error != nil {
                tableView.remote.notifyError()
                return
            }

            if usingRefreshControl {
                self.dataSource?.clearItems()
            }

            self.dataSource?.addItems(items: products)

            tableView.remote.notifySuccess(hasMore: false)
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let product = dataSource?.data[indexPath.row] else { return }
        didSelectItem?(product)
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0
    }
}
