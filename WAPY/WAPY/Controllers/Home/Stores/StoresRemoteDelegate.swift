//
//  StoresRemoteDelegate.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 09/05/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import UIKit
import AZRemoteTable

public class StoresRemoteDelegate: AZRemoteTableDelegate {
    var didSelectItem: ((Store) -> Void)?

    var dataSource: StoresRemoteDataSource? {
        return self.tableView?.remote.dataSource as? StoresRemoteDataSource
    }

    public override func tableView(_ tableView: UITableView, didRequestPage page: Int, usingRefreshControl: Bool = false) {
        API.shared.getStores { [unowned self] (stores, error) in

            // if there was an error, notify the table
            if error != nil {
                tableView.remote.notifyError()
                return
            }

            // in case used refresh controller, clear the data
            if usingRefreshControl {
                self.dataSource?.clearItems()
            }

            // add the items to the data source
            self.dataSource?.addItems(items: stores)

            // notify success
            tableView.remote.notifySuccess(hasMore: false)
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let product = dataSource?.data[indexPath.row] else { return }
        didSelectItem?(product)
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300.0
    }
}
