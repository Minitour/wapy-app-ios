//
//  CameraRemoteDelegate.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 15/05/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import Foundation
import UIKit
import AZRemoteTable

public class CameraRemoteDelegate: AZRemoteTableDelegate {
    var didSelectItem: ((Camera) -> Void)?

    var storeId: String

    public init(storeId: String) {
        self.storeId = storeId
        super.init()
    }

    var dataSource: CameraRemoteDataSource? {
        return self.tableView?.remote.dataSource as? CameraRemoteDataSource
    }

    public override func tableView(_ tableView: UITableView, didRequestPage page: Int, usingRefreshControl: Bool = false) {
        
        API.shared.getCameras(withStoreId: storeId) { (cameras, error) in
            if error != nil {
                tableView.remote.notifyError()
                return
            }

            if usingRefreshControl {
                self.dataSource?.clearItems()
            }

            self.dataSource?.addItems(items: cameras)

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
